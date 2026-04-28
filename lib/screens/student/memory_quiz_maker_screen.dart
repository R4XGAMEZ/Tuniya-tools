import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class MemoryQuizMakerScreen extends StatefulWidget {
  const MemoryQuizMakerScreen({super.key});
  @override
  State<MemoryQuizMakerScreen> createState() => _MemoryQuizMakerScreenState();
}

class _MemoryQuizMakerScreenState extends State<MemoryQuizMakerScreen> {
  final _notesCtrl = TextEditingController();
  String _questionCount = '5';
  String _difficulty = 'Medium';
  String _result = '';
  bool _loading = false;

  final _counts = ['3', '5', '8', '10'];
  final _difficulties = ['Easy', 'Medium', 'Hard', 'Mixed'];

  Future<void> _generate() async {
    if (_notesCtrl.text.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; });
    try {
      final prompt = '''From these notes, create $_questionCount Memory Recall Quiz questions.
Difficulty: $_difficulty

Notes:
"""
${_notesCtrl.text.trim()}
"""

Format each question as:
Q1. [Question]
Answer: [Short answer]
Memory Tip: [1 line tip to remember this]

Make it test actual recall, not just recognition. Use blanks, definitions, cause-effect style questions.
Hindi/English mix okay for tips.''';
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
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Memory Recall Quiz Maker', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 12)),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.purple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.quiz_outlined, color: AppTheme.purple, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Apne notes paste karo — AI recall-based quiz banayega memory test ke liye!',
                      style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Paste Your Notes', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 7,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Yahan apne notes paste karo...\ne.g. Photosynthesis is the process by which plants use sunlight...',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Number of Questions', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Row(children: _counts.map((c) {
              final sel = c == _questionCount;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _questionCount = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.purple : AppTheme.cardBg2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor),
                  ),
                  child: Center(child: Text(c, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13, fontWeight: sel ? FontWeight.bold : FontWeight.normal))),
                ),
              ));
            }).toList()),
            const SizedBox(height: 14),
            Text('Difficulty', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: _difficulties.map((d) {
              final sel = d == _difficulty;
              return GestureDetector(
                onTap: () => setState(() => _difficulty = d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.purple : AppTheme.cardBg2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor),
                  ),
                  child: Text(d, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
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
                    : const Icon(Icons.psychology_outlined),
                label: Text(_loading ? 'Generating Quiz...' : 'Generate Memory Quiz',
                    style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
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
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
                ),
                child: Text(_result, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.7)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
