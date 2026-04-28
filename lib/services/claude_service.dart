import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class ClaudeService {
  static const _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';
  static const _version = '2023-06-01';

  static ClaudeService? _instance;
  static ClaudeService get instance => _instance ??= ClaudeService._();
  ClaudeService._();

  String get _apiKey => SettingsService().claudeApiKey;
  bool get isReady => _apiKey.isNotEmpty;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
    'anthropic-version': _version,
  };

  static const _timeout = Duration(seconds: 60);

  // ─── Basic text completion ────────────────────────────────────────────────
  Future<String> complete(String prompt, {int maxTokens = 4096, String? system}) async {
    _checkKey();
    final body = <String, dynamic>{
      'model': _model,
      'max_tokens': maxTokens,
      'messages': [{'role': 'user', 'content': prompt}],
    };
    if (system != null) body['system'] = system;
    final res = await http.post(Uri.parse(_baseUrl),
        headers: _headers, body: jsonEncode(body)).timeout(_timeout);
    return _extract(res);
  }

  // ─── Multi-turn chat ─────────────────────────────────────────────────────
  Future<String> chat(List<Map<String, String>> history, {String? system}) async {
    _checkKey();
    final messages = history.map((m) => {
      'role': m['role'] ?? 'user',
      'content': m['text'] ?? '',
    }).toList();
    final body = <String, dynamic>{
      'model': _model,
      'max_tokens': 4096,
      'messages': messages,
    };
    if (system != null) body['system'] = system;
    final res = await http.post(Uri.parse(_baseUrl),
        headers: _headers, body: jsonEncode(body)).timeout(_timeout);
    return _extract(res);
  }

  // ─── PDF Summarizer ───────────────────────────────────────────────────────
  Future<String> summarizePdf(String pdfText) async {
    return complete(
      'Summarize the following document. Provide:\n'
      '1. Main topic (1 line)\n'
      '2. Key points (bullet list)\n'
      '3. Important details\n'
      '4. Conclusion\n\n'
      'Document:\n$pdfText',
      system: 'You are an expert document summarizer. Be concise and clear.',
    );
  }

  // ─── Audio Transcription (text cleanup) ───────────────────────────────────
  Future<String> cleanTranscription(String rawText, String language) async {
    return complete(
      'Clean up this voice transcription. Fix punctuation, grammar, formatting.\n'
      'Language: $language\n\nRaw text:\n$rawText',
      system: 'You are a transcription editor. Return only the cleaned text.',
    );
  }

  // ─── AI Translator ────────────────────────────────────────────────────────
  Future<String> translate(String text, String targetLanguage) async {
    return complete(
      'Translate the following text to $targetLanguage. Return only the translation, nothing else.\n\n$text',
    );
  }

  // ─── Code Helper ─────────────────────────────────────────────────────────
  Future<String> codeHelp(String query, String language) async {
    return complete(
      '$query\n\nLanguage: $language',
      system: 'You are an expert programmer. Provide clear, working code with brief explanations. '
          'Format code in proper code blocks.',
      maxTokens: 8192,
    );
  }

  // ─── Text Writer ─────────────────────────────────────────────────────────
  Future<String> writeText(String type, String topic, String tone, String language) async {
    return complete(
      'Write a $type about: $topic\nTone: $tone\nLanguage: $language\n'
      'Make it engaging and well-structured.',
      maxTokens: 8192,
    );
  }

  // ─── Grammar Fixer ────────────────────────────────────────────────────────
  Future<String> fixGrammar(String text) async {
    return complete(
      'Fix all grammar, spelling, and punctuation errors in this text. '
      'Return only the corrected text:\n\n$text',
    );
  }

  // ─── AI Resume ────────────────────────────────────────────────────────────
  Future<String> makeResume(Map<String, String> details) async {
    final info = details.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    return complete(
      'Create a professional resume in Markdown format with this information:\n$info\n'
      'Include: Contact, Summary, Skills, Experience, Education, Projects sections.',
      maxTokens: 8192,
    );
  }

  // ─── Social Bio ───────────────────────────────────────────────────────────
  Future<String> socialBio(String platform, String about, String vibe) async {
    return complete(
      'Write a $platform bio for someone who: $about\n'
      'Vibe/Style: $vibe\n'
      'Keep it under 150 characters. Make it catchy. No hashtags.',
    );
  }

  // ─── Keyword Generator ─────────────────────────────────────────────────────
  Future<String> generateKeywords(String topic, String platform) async {
    return complete(
      'Generate 20 high-ranking SEO keywords/tags for:\n'
      'Topic: $topic\nPlatform: $platform\n'
      'Return as comma-separated list. Focus on searchability and relevance.',
    );
  }

  // ─── AI Fix Anything ──────────────────────────────────────────────────────
  Future<String> fixAnything(String instruction, String? fileContent) async {
    final content = fileContent != null
        ? 'File content:\n```\n$fileContent\n```\n\nInstruction: $instruction'
        : instruction;
    return complete(content, system:
        'You are an all-purpose AI assistant. Help the user with any task they describe. '
        'Be practical and give actionable results.',
        maxTokens: 8192);
  }

  // ─── Git Helper ────────────────────────────────────────────────────────────
  Future<String> gitCommand(String task) async {
    return complete(
      'Give me the exact git command(s) to: $task\n'
      'Return: 1. The command(s) 2. Brief explanation 3. Warning if destructive.',
      system: 'You are a Git expert. Be concise and accurate.',
    );
  }

  // ─── API Doc Generator ─────────────────────────────────────────────────────
  Future<String> generateApiDoc(String jsonResponse) async {
    return complete(
      'Generate professional API documentation from this JSON response:\n$jsonResponse\n'
      'Include: endpoint description, parameters, response fields, example usage in Markdown.',
      maxTokens: 8192,
    );
  }

  // ─── AI Lyrics/Poem ────────────────────────────────────────────────────────
  Future<String> writeLyrics(String topic, String style, String language) async {
    return complete(
      'Write $style lyrics/poem about: $topic\nLanguage: $language\n'
      'Make it creative and emotionally resonant.',
      maxTokens: 4096,
    );
  }

  // ─── Invoice Generator ─────────────────────────────────────────────────────
  Future<String> generateInvoiceMarkdown(Map<String, dynamic> details) async {
    return complete(
      'Generate a professional invoice in Markdown table format:\n${jsonEncode(details)}\n'
      'Include: Invoice number, date, client details, item table with GST, total amount.',
    );
  }

  // ─── AI Website Builder ────────────────────────────────────────────────────
  Future<String> buildWebsite(String description, String style) async {
    return complete(
      'Build a complete single-page HTML website for: $description\n'
      'Style: $style\nRequirements: Mobile responsive, dark theme, modern CSS animations, '
      'all inline in one HTML file.',
      maxTokens: 8192,
    );
  }

  // ─── Doc Translator ───────────────────────────────────────────────────────
  Future<String> translateDoc(String text, String targetLang) async {
    return complete(
      'Translate this document to $targetLang. Maintain the original formatting and structure:\n\n$text',
      maxTokens: 8192,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  void _checkKey() {
    if (_apiKey.isEmpty) throw Exception('Claude API key nahi dali. Settings mein daal do.');
  }

  String _extract(http.Response res) {
    if (res.statusCode != 200) {
      try {
        final err = jsonDecode(res.body);
        throw Exception(err['error']?['message'] ?? 'Claude API error ${res.statusCode}');
      } catch (_) {
        throw Exception('Claude API error ${res.statusCode}: ${res.body}');
      }
    }
    final data = jsonDecode(res.body);
    final content = data['content'] as List?;
    if (content == null || content.isEmpty) throw Exception('Empty response from Claude');
    return content.map((c) => c['text'] ?? '').join('').trim();
  }
}
