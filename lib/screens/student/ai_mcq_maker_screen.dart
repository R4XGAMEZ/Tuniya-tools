import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class AiMcqMakerScreen extends StatefulWidget {
  const AiMcqMakerScreen({super.key});
  @override
  State<AiMcqMakerScreen> createState() => _AiMcqMakerScreenState();
}

class _AiMcqMakerScreenState extends State<AiMcqMakerScreen> {
  final _notesCtrl = TextEditingController();
  int _numQ = 10;
  String _result = '';
  bool _loading = false;

  Future<void> _generate() async {
    if (_notesCtrl.text.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; });
    try {
      final prompt = '''In notes se exactly $_numQ MCQ questions banao:

NOTES:
${_notesCtrl.text.trim()}

Format (strictly follow this):
1. [Question]
   a) [Option A]
   b) [Option B]
   c) [Option C]
   d) [Option D]
   Answer: [correct option letter]

2. ...''';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.rajdhani()), backgroundColor: isError ? AppTheme.red : AppTheme.purple));
  }

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI MCQ Maker', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_result.isNotEmpty)
            IconButton(icon: const Icon(Icons.copy, color: AppTheme.purple), onPressed: () { Clipboard.setData(ClipboardData(text: _result)); _snack('MCQs copied!'); }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apne Notes Paste Karo', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Chapter notes, textbook content yahan paste karo...',
                    hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                    contentPadding: const EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Questions: $_numQ', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            Slider(value: _numQ.toDouble(), min: 5, max: 30, divisions: 25, activeColor: AppTheme.purple, onChanged: (v) => setState(() => _numQ = v.toInt())),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generate,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.checklist_rtl_outlined),
                label: Text(_loading ? 'Generating MCQs...' : 'Generate MCQs', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 12),
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purple.withOpacity(0.4))),
                  child: SingleChildScrollView(
                    child: Text(_result, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13, height: 1.7)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
