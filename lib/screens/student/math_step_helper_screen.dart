import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class MathStepHelperScreen extends StatefulWidget {
  const MathStepHelperScreen({super.key});
  @override
  State<MathStepHelperScreen> createState() => _MathStepHelperScreenState();
}

class _MathStepHelperScreenState extends State<MathStepHelperScreen> {
  final _ctrl = TextEditingController();
  String _topic = 'Algebra';
  String _result = '';
  bool _loading = false;
  final _topics = ['Algebra', 'Geometry', 'Calculus', 'Statistics', 'Arithmetic', 'Trigonometry', 'Other'];
  final List<String> _history = [];

  Future<void> _solve() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; });
    try {
      final prompt = '''Tum ek expert Math teacher ho ($_topic).
Is problem ko STEP BY STEP solve karo:

Problem: $q

Format:
- Har step numbered likho
- Each step mein kya kar rahe ho explain karo
- Formulas clearly likho
- FINAL ANSWER clearly alag se likho
- Simple Hindi/English mix use karo''';
      final r = await GeminiService.instance.generateContent(prompt);
      if (!mounted) return;
      setState(() {
        _result = r;
        _history.insert(0, q);
        if (_history.length > 10) _history.removeLast();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _result = '⚠️ Error: $e');
    } finally {
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
        title: Text('Math Step Helper', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
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
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _topics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final sel = _topics[i] == _topic;
                  return GestureDetector(
                    onTap: () => setState(() => _topic = _topics[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)),
                      child: Text(_topics[i], style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _ctrl,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Math problem likho... e.g. 2x + 5 = 13, find x\nor: Find area of circle with radius 7cm',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _solve,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.functions_outlined),
                label: Text(_loading ? 'Solving...' : 'Solve Step by Step', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
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
