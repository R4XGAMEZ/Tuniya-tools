import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ExamCountdownScreen extends StatefulWidget {
  const ExamCountdownScreen({super.key});
  @override
  State<ExamCountdownScreen> createState() => _ExamCountdownScreenState();
}

class _ExamCountdownScreenState extends State<ExamCountdownScreen> {
  final List<Map<String, dynamic>> _exams = [];
  final _nameCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  void _addExam() {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() {
      _exams.add({'name': _nameCtrl.text.trim(), 'date': _selectedDate});
      _exams.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      _nameCtrl.clear();
    });
    Navigator.pop(context);
  }

  int _daysLeft(DateTime date) => date.difference(DateTime.now()).inDays;

  Color _urgencyColor(int days) {
    if (days < 0) return Colors.grey;
    if (days <= 3) return AppTheme.red;
    if (days <= 7) return Colors.orange;
    if (days <= 14) return Colors.yellow;
    return Colors.green;
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Exam', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
              const SizedBox(height: 14),
              TextField(
                controller: _nameCtrl,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Exam name (e.g. Math Final, NEET)',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  filled: true, fillColor: AppTheme.cardBg2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx, initialDate: _selectedDate,
                    firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (_, child) => Theme(data: ThemeData.dark(), child: child!),
                  );
                  if (d != null && ctx.mounted) setS(() => _selectedDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.purple)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppTheme.purple, size: 18),
                      const SizedBox(width: 8),
                      Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: GoogleFonts.rajdhani(color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addExam,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: Text('Add Exam', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Exam Countdown Board', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 14)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _exams.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.event_outlined, color: AppTheme.textSecondary, size: 60),
                const SizedBox(height: 12),
                Text('Koi exam nahi', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 16)),
                Text('+ button se exam add karo', style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 13)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exams.length,
              itemBuilder: (_, i) {
                final exam = _exams[i];
                final days = _daysLeft(exam['date'] as DateTime);
                final color = _urgencyColor(days);
                return Dismissible(
                  key: Key('$i${exam['name']}'),
                  onDismissed: (_) => setState(() => _exams.removeAt(i)),
                  background: Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.delete, color: Colors.white)),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color)),
                          child: Center(
                            child: days < 0
                                ? const Icon(Icons.check, color: Colors.grey)
                                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text('$days', style: GoogleFonts.orbitron(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text('days', style: GoogleFonts.rajdhani(color: color, fontSize: 9)),
                                  ]),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exam['name'] as String, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                () { final d = exam['date'] as DateTime; return '${d.day}/${d.month}/${d.year}'; }(),
                                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                              if (days == 0) Text('Aaj hai! 🔥', style: GoogleFonts.rajdhani(color: color, fontSize: 12))
                              else if (days < 0) Text('Ho gaya ✓', style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 12))
                              else if (days <= 3) Text('Urgent! Padhai shuru karo!', style: GoogleFonts.rajdhani(color: color, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
