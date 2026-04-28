import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiResumeScreen extends StatefulWidget {
  const AiResumeScreen({super.key});
  @override
  State<AiResumeScreen> createState() => _AiResumeScreenState();
}

class _AiResumeScreenState extends State<AiResumeScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _jobCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _eduCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  String _output = '';
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _jobCtrl, _skillsCtrl, _expCtrl, _eduCtrl, _summaryCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _generate() async {
    if (_nameCtrl.text.trim().isEmpty || _jobCtrl.text.trim().isEmpty) {
      _showSnack('Name aur Job Title zaroori hain!', isError: true); return;
    }
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final details = {
        'Full Name': _nameCtrl.text.trim(),
        'Email': _emailCtrl.text.trim(),
        'Phone': _phoneCtrl.text.trim(),
        'Target Job Role': _jobCtrl.text.trim(),
        'Skills': _skillsCtrl.text.trim(),
        'Work Experience': _expCtrl.text.trim(),
        'Education': _eduCtrl.text.trim(),
        'About/Summary': _summaryCtrl.text.trim(),
      };
      final res = await ClaudeService.instance.makeResume(details);
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

  Widget _field(String label, TextEditingController ctrl, {String? hint, int lines = 1, bool required = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(children: [
        TextSpan(text: label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
        if (required) TextSpan(text: ' *', style: GoogleFonts.rajdhani(color: AppTheme.red, fontSize: 13)),
      ])),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13),
          filled: true, fillColor: AppTheme.cardBg2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      const SizedBox(height: 12),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Resume Maker', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!ClaudeService.instance.isReady) ApiWarningBanner(needsGemini: false, needsClaude: true),
          const SizedBox(height: 4),
          _field('Full Name', _nameCtrl, hint: 'Rahul Sharma', required: true),
          _field('Target Job Role', _jobCtrl, hint: 'Flutter Developer, Data Analyst...', required: true),
          Row(children: [
            Expanded(child: _field('Email', _emailCtrl, hint: 'email@example.com')),
            const SizedBox(width: 10),
            Expanded(child: _field('Phone', _phoneCtrl, hint: '+91 9999999999')),
          ]),
          _field('Skills', _skillsCtrl, hint: 'Flutter, Python, React, SQL...', lines: 2),
          _field('Work Experience', _expCtrl, hint: 'Company name, role, duration, achievements...', lines: 3),
          _field('Education', _eduCtrl, hint: 'Degree, college, year, percentage...', lines: 2),
          _field('About / Summary', _summaryCtrl, hint: 'Apne baare mein 2-3 lines...', lines: 3),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: _loading ? 'Resume ban raha hai...' : 'Generate Resume 📄',
              onPressed: _generate,
            ),
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Your Resume', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
              GestureDetector(
                onTap: () { Clipboard.setData(ClipboardData(text: _output)); _showSnack('Resume copied!'); },
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
              child: SelectableText(_output, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13, height: 1.6)),
            ),
          ],
        ]),
      ),
    );
  }
}
