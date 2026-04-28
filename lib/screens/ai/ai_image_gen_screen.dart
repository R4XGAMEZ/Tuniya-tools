import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';
import '../../widgets/common_widgets.dart';

class AiImageGenScreen extends StatefulWidget {
  const AiImageGenScreen({super.key});
  @override
  State<AiImageGenScreen> createState() => _AiImageGenScreenState();
}

class _AiImageGenScreenState extends State<AiImageGenScreen> {
  final _promptCtrl = TextEditingController();
  String _style = 'Photorealistic';
  String _ratio = 'Square (1:1)';
  Uint8List? _imageBytes;
  bool _loading = false;

  final _styles = ['Photorealistic', 'Anime', 'Digital Art', 'Oil Painting', 'Watercolor', 'Sketch', 'Pixel Art', '3D Render', 'Cartoon', 'Cinematic'];
  final _ratios = ['Square (1:1)', 'Portrait (9:16)', 'Landscape (16:9)', 'Widescreen'];

  final _promptIdeas = [
    'Futuristic city at night with neon lights',
    'Beautiful Indian girl in traditional outfit',
    'Epic fantasy dragon breathing fire',
    'Cute robot in space with stars',
    'Minecraft world from birds eye view',
  ];

  @override
  void dispose() { _promptCtrl.dispose(); super.dispose(); }

  Future<void> _generate() async {
    if (_promptCtrl.text.trim().isEmpty) {
      _showSnack('Prompt likhna zaroori hai!', isError: true); return;
    }
    if (!GeminiService.instance.isReady) {
      _showSnack('Gemini API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _imageBytes = null; });
    try {
      final fullPrompt = '${_promptCtrl.text.trim()}, style: $_style, aspect ratio: $_ratio';
      final bytes = await GeminiService.instance.generateImage(fullPrompt);
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _saveImage() async {
    if (_imageBytes == null) return;
    try {
      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tuniya_ai_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_imageBytes!);
      _showSnack('Image saved: ${file.path}');
    } catch (e) {
      _showSnack('Save nahi hua: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Image Generator', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
        actions: [
          if (_imageBytes != null)
            IconButton(icon: const Icon(Icons.download, color: AppTheme.purple), onPressed: _saveImage),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!GeminiService.instance.isReady) ApiWarningBanner(needsGemini: true, needsClaude: false),
          const SizedBox(height: 8),
          // Prompt ideas
          Text('Prompt Ideas', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _promptIdeas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => setState(() => _promptCtrl.text = _promptIdeas[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderColor)),
                  child: Text(_promptIdeas[i], style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Prompt *', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _promptCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe karo jo image chahiye...',
              hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
              filled: true, fillColor: AppTheme.cardBg2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Style', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
                child: DropdownButton<String>(
                  value: _style, isExpanded: true, dropdownColor: AppTheme.cardBg2,
                  underline: const SizedBox(),
                  style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
                  items: _styles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _style = v); },
                ),
              ),
            ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ratio', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
                child: DropdownButton<String>(
                  value: _ratio, isExpanded: true, dropdownColor: AppTheme.cardBg2,
                  underline: const SizedBox(),
                  style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
                  items: _ratios.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _ratio = v); },
                ),
              ),
            ])),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: _loading ? 'Image ban rahi hai...' : 'Generate Image 🎨',
              onPressed: _generate,
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            Container(
              width: double.infinity, height: 300,
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const CircularProgressIndicator(color: AppTheme.purple, strokeWidth: 3),
                const SizedBox(height: 16),
                Text('Gemini image bana raha hai...', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)),
              ]),
            )
          else if (_imageBytes != null)
            Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_imageBytes!, width: double.infinity, fit: BoxFit.contain),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: GradientButton(label: 'Save to Gallery 💾', onPressed: _saveImage),
              ),
            ]),
        ]),
      ),
    );
  }
}
