import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class WordCounterScreen extends BaseToolScreen {
  const WordCounterScreen({super.key}) : super(toolId: 'word_counter');
  @override
  State<WordCounterScreen> createState() => _WordCounterScreenState();
}

class _WordCounterScreenState extends BaseToolScreenState<WordCounterScreen> {
  final _ctrl = TextEditingController();
  _Stats _stats = _Stats.empty();

  void _analyze(String text) {
    final words = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).length;
    final chars = text.length;
    final charsNoSpace = text.replaceAll(' ', '').length;
    final lines = text.isEmpty ? 0 : text.split('\n').length;
    final sentences = text.isEmpty
        ? 0
        : text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
    final paragraphs = text.isEmpty
        ? 0
        : text.split(RegExp(r'\n\s*\n')).where((p) => p.trim().isNotEmpty).length;
    final readSec = (words / 200 * 60).round(); // 200 wpm average
    final speakSec = (words / 130 * 60).round(); // 130 wpm speaking

    setState(() => _stats = _Stats(
      words: words, chars: chars, charsNoSpace: charsNoSpace,
      lines: lines, sentences: sentences, paragraphs: paragraphs,
      readSec: readSec, speakSec: speakSec,
    ));
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }


  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Text input
        TextField(
          controller: _ctrl,
          maxLines: 8,
          onChanged: _analyze,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Yahan text paste karo — stats live update honge...',
            alignLabelWithHint: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () { _ctrl.clear(); _analyze(''); },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Main stats grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _statCard('Words',       '${_stats.words}',         Icons.text_fields_outlined,     AppTheme.purple),
            _statCard('Characters',  '${_stats.chars}',         Icons.abc_outlined,             AppTheme.red),
            _statCard('No Spaces',   '${_stats.charsNoSpace}',  Icons.space_bar_outlined,       Colors.blueAccent),
            _statCard('Lines',       '${_stats.lines}',         Icons.format_list_numbered_outlined, Colors.greenAccent),
            _statCard('Sentences',   '${_stats.sentences}',     Icons.short_text_outlined,      Colors.orangeAccent),
            _statCard('Paragraphs',  '${_stats.paragraphs}',    Icons.segment_outlined,         Colors.purpleAccent),
          ],
        ),
        const SizedBox(height: 12),

        // Time estimates
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Time Estimate',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _timeRow(Icons.menu_book_outlined,
                  'Reading Time', _formatTime(_stats.readSec), AppTheme.purple)),
              const SizedBox(width: 16),
              Expanded(child: _timeRow(Icons.record_voice_over_outlined,
                  'Speaking Time', _formatTime(_stats.speakSec), Colors.orangeAccent)),
            ]),
          ]),
        ),

        if (_ctrl.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          // Top words
          _topWordsCard(),
        ],
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: GoogleFonts.orbitron(
                  color: AppTheme.textPrimary, fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _timeRow(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 11)),
        Text(value,
            style: GoogleFonts.orbitron(
                color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ]),
    ]);
  }

  Widget _topWordsCard() {
    final text = _ctrl.text.toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '');
    final stopWords = {'the','a','an','is','are','was','were','in','on','at',
        'to','of','and','or','but','for','with','this','that','it','i','you',
        'he','she','they','we','my','your','his','her','their','our','be','as'};
    final freq = <String, int>{};
    for (final w in text.split(RegExp(r'\s+'))) {
      if (w.length > 2 && !stopWords.contains(w)) {
        freq[w] = (freq[w] ?? 0) + 1;
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    if (top.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Top Words',
            style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...top.map((e) {
          final pct = top.first.value > 0 ? e.value / top.first.value : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              SizedBox(
                width: 80,
                child: Text(e.key,
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.textPrimary, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
              Expanded(child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppTheme.borderColor,
                valueColor: AlwaysStoppedAnimation(AppTheme.purple),
                borderRadius: BorderRadius.circular(4),
              )),
              const SizedBox(width: 8),
              Text('${e.value}x',
                  style: GoogleFonts.rajdhani(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ]),
          );
        }),
      ]),
    );
  }
}

class _Stats {
  final int words, chars, charsNoSpace, lines, sentences, paragraphs;
  final int readSec, speakSec;

  const _Stats({
    required this.words, required this.chars, required this.charsNoSpace,
    required this.lines, required this.sentences, required this.paragraphs,
    required this.readSec, required this.speakSec,
  });

  factory _Stats.empty() => const _Stats(
    words: 0, chars: 0, charsNoSpace: 0, lines: 0,
    sentences: 0, paragraphs: 0, readSec: 0, speakSec: 0,
  );
}
