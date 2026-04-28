import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiFixAnythingScreen extends StatefulWidget {
  const AiFixAnythingScreen({super.key});
  @override
  State<AiFixAnythingScreen> createState() => _AiFixAnythingScreenState();
}

class _AiFixAnythingScreenState extends State<AiFixAnythingScreen> {
  final _instrCtrl = TextEditingController();
  String? _fileName;
  String? _fileContent;
  String _output = '';
  bool _loading = false;

  final _quickPrompts = [
    'Mera code fix karo', 'Iska summary do', 'Is mail ka reply likho',
    'Translate this to Hindi', 'Explain karo step by step', 'Isko improve karo',
  ];

  @override
  void dispose() { _instrCtrl.dispose(); super.dispose(); }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom,
          allowedExtensions: ['txt', 'dart', 'py', 'js', 'java', 'kt', 'html', 'css', 'json', 'xml', 'md', 'csv']);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.path != null) {
        // Read as text (for text files)
        try {
          final content = await file.path.let((p) => Future.value(file.bytes != null ? String.fromCharCodes(file.bytes!) : null));
          if (!mounted) return;
          setState(() { _fileName = file.name; _fileContent = content; });
        } catch (_) {
          if (!mounted) return;
          setState(() { _fileName = file.name; _fileContent = null; });
        }
        _showSnack('File attached: ${file.name}');
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }

  Future<void> _send() async {
    if (_instrCtrl.text.trim().isEmpty) {
      _showSnack('Kya karna hai batao!', isError: true); return;
    }
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final res = await ClaudeService.instance.fixAnything(_instrCtrl.text.trim(), _fileContent);
      if (!mounted) return;
      setState(() => _output = res);
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
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
        title: Text('AI Fix Anything', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!ClaudeService.instance.isReady) ApiWarningBanner(needsGemini: false, needsClaude: true),
          const SizedBox(height: 8),
          // Quick prompts
          Text('Quick Actions', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _quickPrompts.map((p) => GestureDetector(
            onTap: () => setState(() => _instrCtrl.text = p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderColor)),
              child: Text(p, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
            ),
          )).toList() as List<Widget>),
          const SizedBox(height: 14),
          Text('Instruction', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _instrCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Kuch bhi likho — Claude kar dega...',
              hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
              filled: true, fillColor: AppTheme.cardBg2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 12),
          // Attach file
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _fileName != null ? AppTheme.purple.withOpacity(0.1) : AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _fileName != null ? AppTheme.purple.withOpacity(0.5) : AppTheme.borderColor),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_fileName != null ? Icons.attach_file : Icons.add_link, color: AppTheme.purple, size: 18),
                const SizedBox(width: 8),
                Text(_fileName ?? 'File attach karo (optional)', style: GoogleFonts.rajdhani(color: _fileName != null ? AppTheme.textPrimary : AppTheme.textSecondary, fontSize: 13)),
                if (_fileName != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() { _fileName = null; _fileContent = null; }),
                    child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 16),
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: _loading ? 'Claude kaam kar raha hai...' : 'Let Claude Fix It 🔧',
              onPressed: _send,
            ),
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Result', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
              GestureDetector(
                onTap: () { Clipboard.setData(ClipboardData(text: _output)); _showSnack('Copied!'); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.copy, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('Copy', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: SelectableText(_output, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.6)),
            ),
          ],
        ]),
      ),
    );
  }
}

extension _LetExt<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
