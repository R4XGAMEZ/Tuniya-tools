import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class VocabBuilderScreen extends StatefulWidget {
  const VocabBuilderScreen({super.key});
  @override
  State<VocabBuilderScreen> createState() => _VocabBuilderScreenState();
}

class _VocabBuilderScreenState extends State<VocabBuilderScreen> {
  final _searchCtrl = TextEditingController();
  final List<Map<String, String>> _saved = [];
  Map<String, String>? _current;
  bool _loading = false;

  Future<void> _lookup(String word) async {
    if (word.trim().isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _current = null; });
    try {
      final prompt = '''For the word "${word.trim()}", provide:
WORD: ${word.trim()}
MEANING: [simple definition in 1-2 lines]
HINDI: [Hindi meaning]
EXAMPLE: [one example sentence]
SYNONYM: [2-3 synonyms]
ANTONYM: [2-3 antonyms]
USAGE TIP: [when/how to use it]

Keep it concise and student-friendly.''';
      final raw = await GeminiService.instance.generateContent(prompt);
      final parsed = _parse(raw, word.trim());
      if (!mounted) return;
      setState(() => _current = parsed);
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Map<String, String> _parse(String raw, String word) {
    final result = <String, String>{'word': word};
    final keys = ['MEANING', 'HINDI', 'EXAMPLE', 'SYNONYM', 'ANTONYM', 'USAGE TIP'];
    for (final k in keys) {
      final match = RegExp('$k:\\s*(.+?)(?=\\n[A-Z]|\\Z)', dotAll: true).firstMatch(raw);
      if (match != null) result[k.toLowerCase().replaceAll(' ', '_')] = match.group(1)!.trim();
    }
    return result;
  }

  void _save() {
    if (_current == null) return;
    if (!_saved.any((w) => w['word'] == _current!['word'])) {
      setState(() => _saved.insert(0, Map.from(_current!)));
      _snack('Word saved!');
    } else {
      _snack('Already saved!');
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.rajdhani()), backgroundColor: isError ? AppTheme.red : AppTheme.purple));
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Vocabulary Builder', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_saved.isNotEmpty)
            IconButton(icon: const Icon(Icons.bookmark, color: AppTheme.purple), onPressed: _showSaved),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
                    child: TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15),
                      onSubmitted: _lookup,
                      decoration: InputDecoration(hintText: 'Search any word...', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), contentPadding: const EdgeInsets.all(12), border: InputBorder.none, prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : () => _lookup(_searchCtrl.text),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(14)),
                  child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_current != null) Expanded(child: _buildCard()),
            if (_current == null && !_loading)
              Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.abc_outlined, color: AppTheme.textSecondary, size: 60),
                const SizedBox(height: 12),
                Text('Koi bhi word search karo', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 16)),
                Text('Meaning, synonyms, examples milenge', style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 13)),
              ]))),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    final w = _current!;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.purple.withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.purple.withOpacity(0.5))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(w['word'] ?? '', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                Row(children: [
                  IconButton(icon: const Icon(Icons.copy, color: AppTheme.textSecondary, size: 20), onPressed: () { Clipboard.setData(ClipboardData(text: w['word'] ?? '')); _snack('Copied!'); }),
                  IconButton(icon: const Icon(Icons.bookmark_add_outlined, color: AppTheme.purple, size: 22), onPressed: _save),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...[
            ['Meaning', w['meaning'] ?? '', Icons.info_outline],
            ['Hindi', w['hindi'] ?? '', Icons.translate],
            ['Example', w['example'] ?? '', Icons.format_quote_outlined],
            ['Synonyms', w['synonym'] ?? '', Icons.add_circle_outline],
            ['Antonyms', w['antonym'] ?? '', Icons.remove_circle_outline],
            ['Usage Tip', w['usage_tip'] ?? '', Icons.tips_and_updates_outlined],
          ].map((item) => item[1].toString().isEmpty ? const SizedBox() : Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(item[2] as IconData, color: AppTheme.purple, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item[0] as String, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(item[1] as String, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.5)),
              ])),
            ]),
          )),
        ],
      ),
    );
  }

  void _showSaved() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text('Saved Words (${_saved.length})', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16))),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _saved.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () { setState(() => _current = _saved[i]); _searchCtrl.text = _saved[i]['word'] ?? ''; Navigator.pop(context); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_saved[i]['word'] ?? '', style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(_saved[i]['meaning']?.split('.').first ?? '', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
