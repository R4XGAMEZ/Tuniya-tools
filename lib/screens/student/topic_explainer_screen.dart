import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class TopicExplainerScreen extends StatefulWidget {
  const TopicExplainerScreen({super.key});
  @override
  State<TopicExplainerScreen> createState() => _TopicExplainerScreenState();
}

class _TopicExplainerScreenState extends State<TopicExplainerScreen> {
  final _ctrl = TextEditingController();
  int _level = 2;
  String _result = '';
  bool _loading = false;

  final _levelLabels = ['Class 5', 'Class 8', 'Class 10', 'College', 'Expert'];
  final _levelDesc = ['Very simple, examples from daily life', 'Easy language with basics', 'Standard board level', 'University level depth', 'Advanced technical detail'];

  Future<void> _explain() async {
    if (_ctrl.text.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; });
    try {
      final prompt = 'Explain "${_ctrl.text.trim()}" at ${_levelLabels[_level]} level (${_levelDesc[_level]}). Use clear headings, examples, and analogies. Simple Hindi/English mix allowed.';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.rajdhani()), backgroundColor: isError ? AppTheme.red : AppTheme.purple));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Topic Explainer AI', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_result.isNotEmpty)
            IconButton(icon: const Icon(Icons.copy, color: AppTheme.purple), onPressed: () { Clipboard.setData(ClipboardData(text: _result)); _snack('Copied!'); }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _ctrl,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Koi bhi topic likho... e.g. Quantum Physics, French Revolution, DNA',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Explanation Level', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            // Level slider with labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_levelLabels.length, (i) {
                final sel = i == _level;
                return GestureDetector(
                  onTap: () => setState(() => _level = i),
                  child: Column(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.purple : AppTheme.cardBg2,
                        shape: BoxShape.circle,
                        border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor, width: 2),
                      ),
                      child: Center(child: Text('${i + 1}', style: GoogleFonts.orbitron(color: sel ? Colors.white : AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(height: 4),
                    Text(_levelLabels[i], style: GoogleFonts.rajdhani(color: sel ? AppTheme.purple : AppTheme.textSecondary, fontSize: 10)),
                  ]),
                );
              }),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(_levelDesc[_level], style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 11), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _explain,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.school_outlined),
                label: Text(_loading ? 'Explaining...' : 'Explain This Topic', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 12),
            if (_result.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4))),
                  child: SingleChildScrollView(
                    child: Text(_result, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.7)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
