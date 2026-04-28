import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class AiHomeworkHelperScreen extends StatefulWidget {
  const AiHomeworkHelperScreen({super.key});
  @override
  State<AiHomeworkHelperScreen> createState() => _AiHomeworkHelperScreenState();
}

class _AiHomeworkHelperScreenState extends State<AiHomeworkHelperScreen> {
  final _ctrl = TextEditingController();
  String _subject = 'Math';
  String _answer = '';
  bool _loading = false;
  final _subjects = ['Math', 'Science', 'History', 'English', 'Hindi', 'Physics', 'Chemistry', 'Biology', 'Economics', 'Other'];

  Future<void> _solve() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _answer = ''; });
    try {
      final prompt = 'Tum ek expert $_subject teacher ho. Is question ka step-by-step solution do, easy Hindi/English mix mein:\n\nQuestion: $q\n\nHar step clearly explain karo aur final answer bold karo.';
      final result = await GeminiService.instance.chat(prompt);
      if (!mounted) return;
      setState(() => _answer = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _answer = '⚠️ Error: $e');
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Homework Helper', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_answer.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: AppTheme.purple),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _answer));
                _snack('Copied!');
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _subjects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final sel = _subjects[i] == _subject;
                  return GestureDetector(
                    onTap: () => setState(() => _subject = _subjects[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.purple : AppTheme.cardBg2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor),
                      ),
                      child: Text(_subjects[i], style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Text('Question', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _ctrl,
                maxLines: 4,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Homework question yahan likho ya paste karo...',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _solve,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.school_outlined),
                label: Text(_loading ? 'Solving...' : 'Solve Step by Step', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_answer.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_answer, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.6)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
