import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiCodeHelperScreen extends StatefulWidget {
  const AiCodeHelperScreen({super.key});
  @override
  State<AiCodeHelperScreen> createState() => _AiCodeHelperScreenState();
}

class _AiCodeHelperScreenState extends State<AiCodeHelperScreen> {
  final _queryCtrl = TextEditingController();
  String _lang = 'Python';
  String _mode = 'Generate';
  String _output = '';
  bool _loading = false;

  final _langs = ['Python', 'Java', 'JavaScript', 'Dart/Flutter', 'C++', 'Kotlin', 'PHP', 'Shell', 'HTML/CSS', 'SQL'];
  final _modes = ['Generate', 'Explain', 'Fix Bug', 'Optimize', 'Convert', 'Add Comments'];

  @override
  void dispose() { _queryCtrl.dispose(); super.dispose(); }

  Future<void> _ask() async {
    if (_queryCtrl.text.trim().isEmpty) {
      _showSnack('Query likhna zaroori hai!', isError: true); return;
    }
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final prompt = '$_mode: ${_queryCtrl.text.trim()}';
      final res = await ClaudeService.instance.codeHelp(prompt, _lang);
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
        title: Text('AI Code Helper', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!ClaudeService.instance.isReady) ApiWarningBanner(needsGemini: false, needsClaude: true),
          const SizedBox(height: 8),
          // Mode chips
          Text('Mode', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _modes.map((m) {
            final sel = m == _mode;
            return GestureDetector(
              onTap: () => setState(() => _mode = m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: sel ? AppTheme.brandGradient : null,
                  color: sel ? null : AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor),
                ),
                child: Text(m, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          }).toList()),
          const SizedBox(height: 14),
          // Language
          Text('Language', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
            child: DropdownButton<String>(
              value: _lang, isExpanded: true, dropdownColor: AppTheme.cardBg2,
              underline: const SizedBox(),
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
              items: _langs.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) { if (v != null) setState(() => _lang = v); },
            ),
          ),
          const SizedBox(height: 14),
          Text('Query / Code', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _queryCtrl,
            style: GoogleFonts.sourceCodePro(color: AppTheme.textPrimary, fontSize: 13),
            maxLines: 6,
            decoration: InputDecoration(
              hintText: _mode == 'Generate'
                  ? 'Batao kya banana hai... (e.g. login form with validation)'
                  : _mode == 'Fix Bug'
                      ? 'Code paste karo jo theek karna hai...'
                      : 'Apna code ya sawaal likho...',
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
              label: _loading ? 'Claude soch raha hai...' : 'Ask Claude 🤖',
              onTap: _loading ? null : _ask,
            ),
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Answer', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.purple.withOpacity(0.3)),
              ),
              child: SelectableText(_output, style: GoogleFonts.sourceCodePro(color: const Color(0xFFE6EDF3), fontSize: 13, height: 1.6)),
            ),
          ],
        ]),
      ),
    );
  }
}
