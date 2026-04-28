import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class NotesToQuizScreen extends StatefulWidget {
  const NotesToQuizScreen({super.key});
  @override
  State<NotesToQuizScreen> createState() => _NotesToQuizScreenState();
}

class _NotesToQuizScreenState extends State<NotesToQuizScreen> {
  final _notesCtrl = TextEditingController();
  String _quizType = 'MCQ';
  String _questionCount = '5';
  String _result = '';
  bool _loading = false;

  // Quiz attempt state
  List<Map<String, dynamic>> _parsedQuestions = [];
  Map<int, String> _selected = {};
  bool _submitted = false;
  bool _quizMode = false;

  final _types = ['MCQ', 'True/False', 'Fill Blanks', 'Short Answer'];
  final _counts = ['5', '8', '10', '15'];

  Future<void> _generate() async {
    if (_notesCtrl.text.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; _parsedQuestions = []; _selected = {}; _submitted = false; _quizMode = false; });
    try {
      String format = '';
      if (_quizType == 'MCQ') {
        format = '''For each MCQ use EXACTLY this format:
Q[N]. [Question]
A) [Option]
B) [Option]
C) [Option]
D) [Option]
Answer: [A/B/C/D]''';
      } else if (_quizType == 'True/False') {
        format = '''For each question use:
Q[N]. [Statement]
Answer: True/False''';
      } else if (_quizType == 'Fill Blanks') {
        format = '''For each question use:
Q[N]. [Sentence with _____ for blank]
Answer: [word/phrase]''';
      } else {
        format = '''For each question use:
Q[N]. [Question]
Answer: [2-3 line answer]''';
      }

      final prompt = '''Create $_questionCount $_quizType questions from these notes:

"""
${_notesCtrl.text.trim()}
"""

$format

Generate exactly $_questionCount questions. Only output the questions, no extra text.''';

      final r = await GeminiService.instance.generateContent(prompt);
      if (!mounted) return;
      setState(() { _result = r; });

      if (_quizType == 'MCQ') {
        _parseMCQ(r);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _result = '⚠️ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _parseMCQ(String text) {
    final questions = <Map<String, dynamic>>[];
    final lines = text.split('\n');
    Map<String, dynamic>? current;
    final List<String> opts = [];
    String? ans;

    for (final line in lines) {
      final l = line.trim();
      if (RegExp(r'^Q\d+\.').hasMatch(l)) {
        if (current != null && opts.isNotEmpty) {
          current['options'] = List<String>.from(opts);
          current['answer'] = ans ?? '';
          questions.add(current);
        }
        current = {'question': l.replaceFirst(RegExp(r'^Q\d+\.\s*'), '')};
        opts.clear();
        ans = null;
      } else if (RegExp(r'^[A-D]\)').hasMatch(l)) {
        opts.add(l);
      } else if (l.startsWith('Answer:')) {
        ans = l.replaceFirst('Answer:', '').trim();
      }
    }
    if (current != null && opts.isNotEmpty) {
      current['options'] = List<String>.from(opts);
      current['answer'] = ans ?? '';
      questions.add(current);
    }
    setState(() => _parsedQuestions = questions);
  }

  int get _score {
    int s = 0;
    for (int i = 0; i < _parsedQuestions.length; i++) {
      final correct = (_parsedQuestions[i]['answer'] as String).trim().toUpperCase();
      final sel = (_selected[i] ?? '').trim().toUpperCase();
      if (sel.isNotEmpty && correct.startsWith(sel[0])) s++;
    }
    return s;
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  Widget _buildMCQQuiz() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.quiz_outlined, color: AppTheme.purple, size: 16),
            const SizedBox(width: 6),
            Text('Interactive Quiz (${_parsedQuestions.length} Questions)',
                style: GoogleFonts.orbitron(color: AppTheme.purple, fontSize: 11)),
            const Spacer(),
            if (_submitted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.purple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('Score: $_score/${_parsedQuestions.length}',
                    style: GoogleFonts.rajdhani(color: AppTheme.purple, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_parsedQuestions.length, (i) {
          final q = _parsedQuestions[i];
          final options = q['options'] as List<String>;
          final correct = (q['answer'] as String).trim().toUpperCase();
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Q${i + 1}. ${q['question']}',
                    style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...options.map((opt) {
                  final optKey = opt.substring(0, 1).toUpperCase();
                  final isSelected = _selected[i] == optKey;
                  final isCorrect = _submitted && correct.startsWith(optKey);
                  final isWrong = _submitted && isSelected && !isCorrect;
                  Color bg = AppTheme.cardBg;
                  Color border = AppTheme.borderColor;
                  if (isSelected && !_submitted) { bg = AppTheme.purple.withValues(alpha: 0.2); border = AppTheme.purple; }
                  if (isCorrect) { bg = Colors.green.withValues(alpha: 0.15); border = Colors.green; }
                  if (isWrong) { bg = AppTheme.red.withValues(alpha: 0.15); border = AppTheme.red; }
                  return GestureDetector(
                    onTap: _submitted ? null : () => setState(() => _selected[i] = optKey),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected || isCorrect ? border : AppTheme.cardBg2),
                            child: Center(child: Text(optKey, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(opt.substring(2).trim(), style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13))),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        if (!_submitted && _parsedQuestions.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selected.length == _parsedQuestions.length
                  ? () => setState(() => _submitted = true)
                  : null,
              icon: const Icon(Icons.check_circle_outline),
              label: Text('Submit Quiz', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purple, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (_submitted) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _score == _parsedQuestions.length ? Colors.green.withValues(alpha: 0.15) : AppTheme.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _score == _parsedQuestions.length ? Colors.green : AppTheme.purple),
            ),
            child: Column(
              children: [
                Text(_score == _parsedQuestions.length ? '🎉 Perfect Score!' : '📊 Result',
                    style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 14)),
                const SizedBox(height: 6),
                Text('$_score / ${_parsedQuestions.length} correct',
                    style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() { _selected = {}; _submitted = false; }),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text('Try Again', style: GoogleFonts.rajdhani(fontSize: 14)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.purple,
                side: const BorderSide(color: AppTheme.purple),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Notes to Quiz AI', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
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
            Text('Paste Your Notes', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 6,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Apne notes yahan paste karo...',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Quiz Type', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
              final sel = t == _quizType;
              return GestureDetector(
                onTap: () => setState(() => _quizType = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.purple : AppTheme.cardBg2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor),
                  ),
                  child: Text(t, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                ),
              );
            }).toList()),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generate,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome_outlined),
                label: Text(_loading ? 'Generating Quiz...' : 'Generate Quiz from Notes',
                    style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (_result.isNotEmpty && _parsedQuestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildMCQQuiz(),
            ] else if (_result.isNotEmpty && _quizType != 'MCQ') ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4)),
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
