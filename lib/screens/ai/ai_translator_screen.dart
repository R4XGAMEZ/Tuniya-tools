import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiTranslatorScreen extends StatefulWidget {
  const AiTranslatorScreen({super.key});
  @override
  State<AiTranslatorScreen> createState() => _AiTranslatorScreenState();
}

class _AiTranslatorScreenState extends State<AiTranslatorScreen> {
  final _inputCtrl = TextEditingController();
  String _targetLang = 'Hindi';
  String _output = '';
  bool _loading = false;

  final _langs = ['Hindi', 'English', 'Hinglish', 'Urdu', 'Bengali', 'Marathi', 'Tamil', 'Telugu',
    'Gujarati', 'Punjabi', 'French', 'Spanish', 'German', 'Arabic', 'Japanese', 'Chinese', 'Russian', 'Korean'];

  @override
  void dispose() { _inputCtrl.dispose(); super.dispose(); }

  Future<void> _translate() async {
    if (_inputCtrl.text.trim().isEmpty) {
      _showSnack('Text likhna toh padega!', isError: true); return;
    }
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final res = await ClaudeService.instance.translate(_inputCtrl.text.trim(), _targetLang);
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

  void _swap() {
    if (_output.isEmpty) return;
    setState(() {
      _inputCtrl.text = _output;
      _output = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Translator', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (!ClaudeService.instance.isReady) ApiWarningBanner(needsGemini: false, needsClaude: true),
          const SizedBox(height: 8),
          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Input Text', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
                if (_inputCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () { setState(() { _inputCtrl.clear(); _output = ''; }); },
                    child: Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
                  ),
              ]),
              const SizedBox(height: 8),
              TextField(
                controller: _inputCtrl,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Yahan text likho ya paste karo...',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  border: InputBorder.none,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // Target lang + swap
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
                child: DropdownButton<String>(
                  value: _targetLang, isExpanded: true, dropdownColor: AppTheme.cardBg2,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppTheme.purple),
                  style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                  items: _langs.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _targetLang = v); },
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _swap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
                child: const Icon(Icons.swap_vert, color: AppTheme.purple, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _loading ? null : _translate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Translate', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13))),
                ),
              ),
            ),
          ]),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_targetLang, style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 13, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () { Clipboard.setData(ClipboardData(text: _output)); _showSnack('Copied!'); },
                    child: const Icon(Icons.copy, color: AppTheme.textSecondary, size: 18),
                  ),
                ]),
                const SizedBox(height: 10),
                SelectableText(_output, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 16, height: 1.6)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
