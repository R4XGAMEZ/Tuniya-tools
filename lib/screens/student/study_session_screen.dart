import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class StudySessionScreen extends StatefulWidget {
  const StudySessionScreen({super.key});
  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  final _topicCtrl = TextEditingController();
  String _duration = '1 Hour';
  String _style = 'Balanced';
  String _result = '';
  bool _loading = false;

  final _durations = ['30 Mins', '1 Hour', '2 Hours', '3 Hours'];
  final _styles = ['Balanced', 'Deep Focus', 'Quick Revision', 'Practice Heavy'];

  Future<void> _generate() async {
    if (_topicCtrl.text.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; });
    try {
      final prompt = '''Create a detailed $_duration study session plan for: "${_topicCtrl.text.trim()}"
Style: $_style

Include:
- Time-blocked schedule (minute by minute)
- What to study in each block
- Break times
- Active recall exercises
- End-of-session review tasks

Use emojis for visual appeal. Hindi/English mix okay.''';
      final r = await GeminiService.instance.generateContent(prompt);
      if (!mounted) return;
      setState(() => _result = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _result = '⚠️ Error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  @override
  void dispose() { _topicCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Study Session Generator', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
        actions: [
          if (_result.isNotEmpty)
            IconButton(icon: const Icon(Icons.copy, color: AppTheme.purple),
              onPressed: () { Clipboard.setData(ClipboardData(text: _result)); _snack('Copied!'); }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Topic / Subject', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _topicCtrl,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Organic Chemistry Chapter 5, Data Structures...',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Session Duration', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Row(children: _durations.map((d) {
              final sel = d == _duration;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _duration = d),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)),
                  child: Center(child: Text(d, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal))),
                ),
              ));
            }).toList()),
            const SizedBox(height: 14),
            Text('Study Style', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: _styles.map((s) {
              final sel = s == _style;
              return GestureDetector(
                onTap: () => setState(() => _style = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)),
                  child: Text(s, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generate,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.menu_book_outlined),
                label: Text(_loading ? 'Generating Session...' : 'Generate Study Session', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4))),
                child: Text(_result, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.7)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
