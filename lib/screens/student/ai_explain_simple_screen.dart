import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class AiExplainSimpleScreen extends StatefulWidget {
  const AiExplainSimpleScreen({super.key});
  @override
  State<AiExplainSimpleScreen> createState() => _AiExplainSimpleScreenState();
}

class _AiExplainSimpleScreenState extends State<AiExplainSimpleScreen> {
  final _ctrl = TextEditingController();
  String _level = '5th Class';
  String _result = '';
  bool _loading = false;
  final _levels = ['5th Class', '8th Class', '10th Class', 'College', 'Expert'];

  Future<void> _explain() async {
    final topic = _ctrl.text.trim();
    if (topic.isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _result = ''; });
    try {
      final prompt = 'Explain "$topic" in very simple language as if explaining to a $_level student. Use Hindi/English mix. Use simple words, examples from daily life, and analogies. Keep it short and engaging.';
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Explain Simple', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_result.isNotEmpty)
            IconButton(icon: const Icon(Icons.copy, color: AppTheme.purple),
              onPressed: () { Clipboard.setData(ClipboardData(text: _result)); _snack('Copied!'); }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explain as per level', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _levels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final sel = _levels[i] == _level;
                  return GestureDetector(
                    onTap: () => setState(() => _level = _levels[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.purple : AppTheme.cardBg2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor),
                      ),
                      child: Text(_levels[i], style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _ctrl,
                maxLines: 3,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Koi bhi topic likho... e.g. Photosynthesis, Gravity, Democracy',
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
                onPressed: _loading ? null : _explain,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.lightbulb_outlined),
                label: Text(_loading ? 'Explaining...' : 'Explain Now', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_result.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_result, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.6)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
