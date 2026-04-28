import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class StudyScheduleScreen extends StatefulWidget {
  const StudyScheduleScreen({super.key});
  @override
  State<StudyScheduleScreen> createState() => _StudyScheduleScreenState();
}

class _StudyScheduleScreenState extends State<StudyScheduleScreen> {
  final _subjectsCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  String _goal = 'Exam Prep';
  String _days = '7 Days';
  String _result = '';
  bool _loading = false;

  final _goals = ['Exam Prep', 'Daily Study', 'Revision', 'Project Work'];
  final _dayOptions = ['3 Days', '7 Days', '14 Days', '30 Days'];

  Future<void> _build() async {
    if (_subjectsCtrl.text.trim().isEmpty || _hoursCtrl.text.trim().isEmpty) {
      _snack('Subjects aur daily hours bharo', isError: true);
      return;
    }
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; });
    try {
      final prompt = '''Create a detailed study schedule:
- Subjects: ${_subjectsCtrl.text.trim()}
- Daily Study Hours: ${_hoursCtrl.text.trim()} hours
- Goal: $_goal
- Duration: $_days

Make a day-wise schedule with:
- Time slots for each subject
- Short breaks
- Revision time
- Weekly targets

Format it clearly with days and times. Use simple Hindi/English mix.''';
      final r = await GeminiService.instance.chat(prompt);
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
  void dispose() { _subjectsCtrl.dispose(); _hoursCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Study Schedule Builder', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 14)),
        actions: [
          if (_result.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: AppTheme.purple),
              onPressed: () { Clipboard.setData(ClipboardData(text: _result)); _snack('Schedule copied!'); },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subjects', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _subjectsCtrl,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Math, Physics, Chemistry, English',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Daily Study Hours', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _hoursCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. 4',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                  suffixText: 'hours/day',
                  suffixStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Goal', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _goals.map((g) {
                final sel = g == _goal;
                return GestureDetector(
                  onTap: () => setState(() => _goal = g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)),
                    child: Text(g, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text('Duration', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              children: _dayOptions.map((d) {
                final sel = d == _days;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _days = d),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)),
                      child: Center(child: Text(d, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _build,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.calendar_today_outlined),
                label: Text(_loading ? 'Building Schedule...' : 'Build My Schedule', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
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
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purple.withOpacity(0.4))),
                child: Text(_result, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.7)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
