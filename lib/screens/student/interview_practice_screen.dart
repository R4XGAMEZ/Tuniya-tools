import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class InterviewPracticeScreen extends StatefulWidget {
  const InterviewPracticeScreen({super.key});
  @override
  State<InterviewPracticeScreen> createState() => _InterviewPracticeScreenState();
}

class _InterviewPracticeScreenState extends State<InterviewPracticeScreen> {
  final _answerCtrl = TextEditingController();
  String _field = 'Software Engineer';
  String _level = 'Fresher';
  String _currentQ = '';
  String _feedback = '';
  bool _loadingQ = false;
  bool _loadingFb = false;
  bool _answered = false;

  final _fields = ['Software Engineer', 'Data Science', 'Marketing', 'Finance', 'HR', 'Teaching', 'Medical', 'Other'];
  final _levels = ['Fresher', 'Mid-Level', 'Senior'];

  Future<void> _getQuestion() async {
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loadingQ = true; _currentQ = ''; _feedback = ''; _answered = false; _answerCtrl.clear(); });
    try {
      final prompt = 'Give me ONE interview question for a $_level $_field position. Just the question, nothing else.';
      final r = await GeminiService.instance.chat(prompt);
      if (!mounted) return;
      setState(() => _currentQ = r.trim());
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loadingQ = false);
    }
  }

  Future<void> _getFeedback() async {
    if (_answerCtrl.text.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) return;
    setState(() { _loadingFb = true; _feedback = ''; });
    try {
      final prompt = '''Interview Question: "$_currentQ"
Candidate Answer: "${_answerCtrl.text.trim()}"

Role: $_level $_field

Give constructive feedback:
1. Kya achha tha answer mein
2. Kya improve ho sakta hai
3. Better answer ka example (short)
4. Overall rating: X/10

Use simple Hindi/English mix.''';
      final r = await GeminiService.instance.chat(prompt);
      if (!mounted) return;
      setState(() { _feedback = r; _answered = true; });
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loadingFb = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.rajdhani()), backgroundColor: isError ? AppTheme.red : AppTheme.purple));
  }

  @override
  void dispose() { _answerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Interview Practice', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field
            Text('Field', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            SizedBox(height: 36, child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _fields.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final sel = _fields[i] == _field;
                return GestureDetector(
                  onTap: () => setState(() => _field = _fields[i]),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)), child: Text(_fields[i], style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12))),
                );
              },
            )),
            const SizedBox(height: 10),
            // Level
            Row(children: _levels.map((l) {
              final sel = l == _level;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _level = l),
                child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)), child: Center(child: Text(l, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)))),
              ));
            }).toList()),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadingQ ? null : _getQuestion,
                icon: _loadingQ ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.question_answer_outlined),
                label: Text(_loadingQ ? 'Getting Question...' : _currentQ.isEmpty ? 'Start Interview' : 'Next Question', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            if (_currentQ.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purple.withOpacity(0.5))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.person_outlined, color: AppTheme.purple, size: 18), const SizedBox(width: 6), Text('Interviewer', style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 12, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 8),
                  Text(_currentQ, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15, height: 1.5, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 12),
              Text('Your Answer', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
                child: TextField(
                  controller: _answerCtrl,
                  maxLines: 4,
                  style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(hintText: 'Apna answer yahan likho...', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), contentPadding: const EdgeInsets.all(12), border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadingFb ? null : _getFeedback,
                  icon: _loadingFb ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.rate_review_outlined),
                  label: Text(_loadingFb ? 'Getting Feedback...' : 'Get AI Feedback', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              if (_feedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.07), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.4))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AI Feedback', style: GoogleFonts.rajdhani(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_feedback, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.6)),
                  ]),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
