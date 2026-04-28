import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class GeminiService {
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const _model = 'gemini-2.0-flash';
  static const _imageModel = 'gemini-2.0-flash-exp-image-generation';
  static const _timeout = Duration(seconds: 60);

  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();
  GeminiService._();

  String get _apiKey => SettingsService().geminiApiKey;

  bool get isReady => _apiKey.isNotEmpty;

  // ─── Text / Chat ─────────────────────────────────────────────────────────
  Future<String> chat(String prompt) async {
    _checkKey();
    final url = '$_baseUrl/models/$_model:generateContent?key=$_apiKey';
    final body = jsonEncode({
      'contents': [{'parts': [{'text': prompt}]}],
      'generationConfig': {'maxOutputTokens': 8192, 'temperature': 0.7},
    });
    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body).timeout(_timeout);
    return _extractText(res);
  }

  // ─── Multi-turn Chat ──────────────────────────────────────────────────────
  Future<String> chatMultiTurn(List<Map<String, String>> history) async {
    _checkKey();
    final url = '$_baseUrl/models/$_model:generateContent?key=$_apiKey';
    final contents = history.map((m) => {
      'role': m['role'] == 'user' ? 'user' : 'model',
      'parts': [{'text': m['text']}],
    }).toList();
    final body = jsonEncode({'contents': contents});
    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body).timeout(_timeout);
    return _extractText(res);
  }

  // ─── Image + Text (Vision) ────────────────────────────────────────────────
  Future<String> analyzeImage(File imageFile, String prompt) async {
    _checkKey();
    final bytes = await imageFile.readAsBytes();
    final b64 = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    final url = '$_baseUrl/models/$_model:generateContent?key=$_apiKey';
    final body = jsonEncode({
      'contents': [{
        'parts': [
          {'inline_data': {'mime_type': mime, 'data': b64}},
          {'text': prompt},
        ]
      }],
    });
    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body).timeout(_timeout);
    return _extractText(res);
  }

  // ─── YouTube Video Analysis ─────────────────────────────────────────────────
  // Note: Gemini cannot directly fetch YouTube URLs via file_data.
  // We send the URL as text context for Gemini to analyze based on its training knowledge.
  Future<String> analyzeYouTube(String youtubeUrl, String prompt) async {
    _checkKey();
    final url = '$_baseUrl/models/$_model:generateContent?key=$_apiKey';
    final body = jsonEncode({
      'contents': [{
        'parts': [
          {
            'text': 'YouTube video URL: $youtubeUrl\n\n'
                'Task: $prompt\n\n'
                'Note: Analyze this YouTube video based on the URL context, '
                'title, channel info if recognizable, and provide insights.',
          },
        ]
      }],
      'generationConfig': {'maxOutputTokens': 4096, 'temperature': 0.7},
    });
    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body).timeout(_timeout);
    return _extractText(res);
  }

  // ─── Image Generation ─────────────────────────────────────────────────────
  Future<Uint8List?> generateImage(String prompt) async {
    _checkKey();
    final url = '$_baseUrl/models/$_imageModel:generateContent?key=$_apiKey';
    final body = jsonEncode({
      'contents': [{'parts': [{'text': prompt}]}],
      'generationConfig': {'responseModalities': ['TEXT', 'IMAGE']},
    });
    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body).timeout(_timeout);
    if (res.statusCode != 200) throw Exception('Image gen failed: ${res.body}');
    final data = jsonDecode(res.body);
    final parts = data['candidates']?[0]?['content']?['parts'] as List?;
    if (parts == null) return null;
    for (final part in parts) {
      if (part['inline_data'] != null) {
        return base64Decode(part['inline_data']['data']);
      }
    }
    return null;
  }

  // ─── Image Upscale (using Gemini vision prompt) ───────────────────────────
  Future<String> upscaleImagePrompt(File imageFile, int factor) async {
    return analyzeImage(imageFile,
        'Describe this image in extreme detail so it can be reconstructed at ${factor}x resolution. '
        'Include all colors, textures, objects, lighting, shadows, and composition precisely.');
  }

  // ─── Gender Change ─────────────────────────────────────────────────────────
  Future<String> genderChangeAnalysis(File imageFile, String targetGender) async {
    return analyzeImage(imageFile,
        'Describe every facial feature, hair, skin tone, body structure in this image in extreme detail. '
        'Then describe how this person would look as a $targetGender maintaining same age and ethnicity.');
  }

  // ─── OCR ──────────────────────────────────────────────────────────────────
  Future<String> extractText(File imageFile) async {
    return analyzeImage(imageFile,
        'Extract ALL text visible in this image. Return only the text exactly as it appears, '
        'maintaining line breaks and formatting. Nothing else.');
  }

  // ─── Image to Prompt ──────────────────────────────────────────────────────
  Future<String> imageToPrompt(File imageFile) async {
    return analyzeImage(imageFile,
        'Generate a detailed AI image generation prompt for this image. '
        'Include style, colors, lighting, composition, subject, mood. '
        'Format: [subject], [style], [colors], [lighting], [mood], [camera angle]');
  }

  // ─── Image to Recipe ──────────────────────────────────────────────────────
  Future<String> imageToRecipe(File imageFile) async {
    return analyzeImage(imageFile,
        'Identify all food items visible in this image. '
        'Then suggest 2-3 recipes I can make with these ingredients. '
        'Include ingredients list and step-by-step instructions in simple language.');
  }

  // ─── Background Remover Prompt ────────────────────────────────────────────
  Future<String> analyzeForBgRemoval(File imageFile) async {
    return analyzeImage(imageFile,
        'Describe the main subject of this image in detail, including exact boundaries, '
        'colors, and how it differs from the background. '
        'This will be used to segment and remove the background.');
  }

  // ─── AI Website Builder ────────────────────────────────────────────────────
  Future<String> wireframeToHtml(File wireframeImage, String description) async {
    return analyzeImage(wireframeImage,
        'This is a hand-drawn website wireframe. Convert it to complete HTML/CSS code. '
        'Description: $description\n'
        'Requirements: Dark theme, modern design, responsive, inline CSS. '
        'Return ONLY the complete HTML code, nothing else.');
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  void _checkKey() {
    if (_apiKey.isEmpty) throw Exception('Gemini API key nahi dali. Settings mein daal do.');
  }

  String _extractText(http.Response res) {
    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err['error']?['message'] ?? 'Gemini API error ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    final parts = data['candidates']?[0]?['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) throw Exception('Empty response from Gemini');
    return parts.map((p) => p['text'] ?? '').join('').trim();
  }
}
