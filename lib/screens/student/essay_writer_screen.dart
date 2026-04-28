import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class EssayWriterScreen extends StatefulWidget {
  const EssayWriterScreen({super.key});
  @override
  State<EssayWriterScreen> createState() => _EssayWriterScreenState();
}

class _EssayWriterScreenState extends State<EssayWriterScreen> {
  final _topicCtrl = TextEditingController();
  String _type = 'Argumentative';
  int _words = 300;
  String _lang = 'English';
  String _essay = '';
  bool _loading = false;

  final _types = ['Argumentative', 'Descriptive', 'Narrative', 'Expository', 'Persuasive'];
  final _langs = ['English', 'Hindi', 'Hinglish'];

  Future<void> _write() async {
    if (_topicCtrl.text.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _essay = ''; });
    try {
      final prompt = 'Write a $_type essay on: "${_topicCtrl.text.trim()}"\nWord count: approximately $_words words\nLanguage: $_lang\nMake it well-structured with introduction, body paragraphs, and conclusion.';
      final r = await GeminiService.instance.chat(prompt);
      if (!mounted) return;
      setState(() => _essay = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _essay = '⚠️ Error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.rajdhani()), backgroundColor: isError ? AppTheme.red : AppTheme.purple));
  }

  @override
  void dispose() { _topicCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Essay Writer AI', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_essay.isNotEmpty)
            IconButton(icon: const Icon(Icons.copy, color: AppTheme.purple), onPressed: () { Clipboard.setData(ClipboardData(text: _essay)); _snack('Essay copied!'); }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Essay Topic', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _topicCtrl,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(hintText: 'e.g. Climate Change, Social Media Impact, Education System', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), contentPadding: const EdgeInsets.all(12), border: InputBorder.none),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 14),
            Text('Essay Type', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
              final sel = t == _type;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)),
                  child: Text(t, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                ),
              );
            }).toList()),
            const SizedBox(height: 14),
            Text('Word Count: $_words', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            Slider(value: _words.toDouble(), min: 150, max: 1000, divisions: 17, activeColor: AppTheme.purple, onChanged: (v) => setState(() => _words = (v / 50).round() * 50)),
            const SizedBox(height: 8),
            Text('Language', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Row(children: _langs.map((l) {
              final sel = l == _lang;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _lang = l),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)),
                  child: Center(child: Text(l, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13))),
                ),
              ));
            }).toList()),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _write,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.edit_note_outlined),
                label: Text(_loading ? 'Writing...' : 'Write Essay', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            if (_essay.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purple.withOpacity(0.4))),
                child: Text(_essay, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.7)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
