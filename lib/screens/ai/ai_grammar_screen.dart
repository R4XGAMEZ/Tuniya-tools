import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiGrammarScreen extends StatefulWidget {
  const AiGrammarScreen({super.key});
  @override
  State<AiGrammarScreen> createState() => _AiGrammarScreenState();
}

class _AiGrammarScreenState extends State<AiGrammarScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  bool _loading = false;

  @override
  void dispose() { _inputCtrl.dispose(); super.dispose(); }

  Future<void> _fix() async {
    if (_inputCtrl.text.trim().isEmpty) {
      _showSnack('Text toh daal pehle!', isError: true); return;
    }
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final res = await ClaudeService.instance.fixGrammar(_inputCtrl.text.trim());
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
        title: Text('AI Grammar Fixer', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!ClaudeService.instance.isReady) ApiWarningBanner(needsGemini: false, needsClaude: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cardBg.withOpacity(0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.purple.withOpacity(0.2))),
            child: Row(children: [
              const Icon(Icons.spellcheck, color: AppTheme.purple, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Hinglish, English ya kisi bhi language ka text paste karo — Claude grammar, spelling aur punctuation fix karega.',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13))),
            ]),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _inputCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15),
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Yahan text paste karo jise fix karna hai...',
              hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
              filled: true, fillColor: AppTheme.cardBg2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: _loading ? 'Fix ho raha hai...' : 'Fix Grammar ✅',
              onPressed: _loading ? null : _fix,
            ),
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Fixed Text', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
              Row(children: [
                GestureDetector(
                  onPressed: () { _inputCtrl.text = _output; setState(() => _output = ''); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderColor)),
                    child: Text('Re-fix', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                  ),
                ),
                GestureDetector(
                  onPressed: () { Clipboard.setData(ClipboardData(text: _output)); _showSnack('Copied!'); },
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
            ]),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
              ),
              child: SelectableText(_output, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15, height: 1.6)),
            ),
          ],
        ]),
      ),
    );
  }
}
