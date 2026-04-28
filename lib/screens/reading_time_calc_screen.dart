import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class ReadingTimeCalcScreen extends BaseToolScreen {
  const ReadingTimeCalcScreen({super.key})
      : super(toolId: 'reading_time_calc');
  @override
  State<ReadingTimeCalcScreen> createState() => _ReadingTimeCalcScreenState();
}

class _ReadingTimeCalcScreenState
    extends BaseToolScreenState<ReadingTimeCalcScreen> {
  final _ctrl = TextEditingController();
  int _selectedWpm = 200;
  _ReadResult? _result;

  static const _speeds = [
    _SpeedOption('Slow', 120, 'New reader / difficult content'),
    _SpeedOption('Average', 200, 'Normal adult reading speed'),
    _SpeedOption('Fast', 300, 'Practiced reader'),
    _SpeedOption('Speed Read', 500, 'Skimming / expert reader'),
  ];

  void _analyze(String text) {
    if (text.trim().isEmpty) {
      setState(() => _result = null);
      return;
    }
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final chars = text.length;
    final sentences = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
    final paragraphs = text.split(RegExp(r'\n\s*\n')).where((p) => p.trim().isNotEmpty).length;

    // Flesch reading ease
    final syllables = _countSyllables(text);
    final fleschScore = sentences == 0 || words == 0
        ? 0.0
        : 206.835 - 1.015 * (words / sentences) - 84.6 * (syllables / words);
    final difficulty = _getDifficulty(fleschScore.clamp(0, 100));

    setState(() => _result = _ReadResult(
      words: words,
      chars: chars,
      sentences: sentences,
      paragraphs: paragraphs,
      fleschScore: fleschScore.clamp(0, 100),
      difficulty: difficulty,
      syllables: syllables,
    ));
  }

  int _countSyllables(String text) {
    // Approximate syllable count
    int count = 0;
    final words = text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '').split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.isEmpty) continue;
      final vowels = word.replaceAll(RegExp(r'[^aeiou]'), '').length;
      count += vowels == 0 ? 1 : vowels;
    }
    return count;
  }

  _DifficultyLevel _getDifficulty(double score) {
    if (score >= 90) return _DifficultyLevel('Very Easy', Colors.greenAccent, 'Bacche bhi samjhein');
    if (score >= 70) return _DifficultyLevel('Easy', const Color(0xFF50C878), 'General audience');
    if (score >= 60) return _DifficultyLevel('Standard', Colors.blueAccent, 'Teen+ readers');
    if (score >= 50) return _DifficultyLevel('Fairly Difficult', Colors.orangeAccent, 'College level');
    if (score >= 30) return _DifficultyLevel('Difficult', AppTheme.red, 'Academic / professional');
    return _DifficultyLevel('Very Difficult', const Color(0xFF8B0000), 'Expert / technical');
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds} sec';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m < 60) return s == 0 ? '${m} min' : '${m}m ${s}s';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
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
        // Speed selector
        _speedSelector(),
        const SizedBox(height: 16),

        // Text input
        TextField(
          controller: _ctrl,
          maxLines: 7,
          onChanged: _analyze,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Text paste karo ya likhna shuru karo...',
            alignLabelWithHint: true,
            suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
              if (_ctrl.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _ctrl.text));
                    showSnack('Copied!');
                  },
                ),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () { _ctrl.clear(); _analyze(''); },
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        if (_result != null) ...[
          _timeResultCard(_result!),
          const SizedBox(height: 16),
          _allSpeedsCard(_result!),
          const SizedBox(height: 16),
          _readabilityCard(_result!),
          const SizedBox(height: 16),
          _statsGrid(_result!),
        ] else
          _emptyHint(),
      ]),
    );
  }

  Widget _speedSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Reading Speed',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(children: _speeds.map((s) {
          final selected = _selectedWpm == s.wpm;
          return Expanded(child: GestureDetector(
            onTap: () {
              setState(() => _selectedWpm = s.wpm);
              _analyze(_ctrl.text);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.purple : AppTheme.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: selected ? AppTheme.purple : AppTheme.borderColor),
              ),
              child: Column(children: [
                Text(s.label,
                    style: GoogleFonts.rajdhani(
                        color: selected ? Colors.white : AppTheme.textSecondary,
                        fontSize: 11, fontWeight: FontWeight.w600)),
                Text('${s.wpm}wpm',
                    style: GoogleFonts.orbitron(
                        color: selected ? Colors.white70 : AppTheme.textSecondary,
                        fontSize: 9)),
              ]),
            ),
          ));
        }).toList()),
      ]),
    );
  }

  Widget _timeResultCard(_ReadResult r) {
    final sec = (r.words / _selectedWpm * 60).round();
    final speed = _speeds.firstWhere((s) => s.wpm == _selectedWpm);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4), width: 1.5),
        gradient: LinearGradient(
          colors: [AppTheme.purple.withValues(alpha: 0.08), AppTheme.cardBg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(children: [
        Text('Reading Time',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Text(_formatTime(sec),
            style: GoogleFonts.orbitron(
                color: AppTheme.purple, fontSize: 36,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('at ${_selectedWpm} WPM — ${speed.desc}',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _allSpeedsCard(_ReadResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('All Reading Speeds',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._speeds.map((s) {
          final sec = (r.words / s.wpm * 60).round();
          final selected = s.wpm == _selectedWpm;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppTheme.purple : AppTheme.borderColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(s.label,
                  style: GoogleFonts.rajdhani(
                      color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
              Text('${s.wpm} WPM',
                  style: GoogleFonts.rajdhani(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                child: Text(_formatTime(sec),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.orbitron(
                        color: selected ? AppTheme.purple : AppTheme.textPrimary,
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _readabilityCard(_ReadResult r) {
    final score = r.fleschScore;
    final d = r.difficulty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Readability Score (Flesch)',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: d.color.withValues(alpha: 0.15),
              border: Border.all(color: d.color, width: 2),
            ),
            child: Center(
              child: Text('${score.toInt()}',
                  style: GoogleFonts.orbitron(
                      color: d.color, fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.label,
                style: GoogleFonts.rajdhani(
                    color: d.color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(d.desc,
                style: GoogleFonts.rajdhani(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ])),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation(d.color),
          ),
        ),
      ]),
    );
  }

  Widget _statsGrid(_ReadResult r) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _statCard('Words', '${r.words}', Icons.text_fields_outlined, AppTheme.purple),
        _statCard('Characters', '${r.chars}', Icons.abc_outlined, Colors.blueAccent),
        _statCard('Sentences', '${r.sentences}', Icons.short_text_outlined, Colors.orangeAccent),
        _statCard('Paragraphs', '${r.paragraphs}', Icons.segment_outlined, Colors.greenAccent),
      ],
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

  Widget _emptyHint() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Icon(Icons.timer_outlined,
            color: AppTheme.textSecondary.withValues(alpha: 0.4), size: 56),
        const SizedBox(height: 16),
        Text('Kuch text paste karo',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 16)),
        const SizedBox(height: 6),
        Text('Reading time aur difficulty score milega',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 13)),
      ]),
    );
  }
}

class _SpeedOption {
  final String label;
  final int wpm;
  final String desc;
  const _SpeedOption(this.label, this.wpm, this.desc);
}

class _DifficultyLevel {
  final String label;
  final Color color;
  final String desc;
  const _DifficultyLevel(this.label, this.color, this.desc);
}

class _ReadResult {
  final int words, chars, sentences, paragraphs, syllables;
  final double fleschScore;
  final _DifficultyLevel difficulty;
  const _ReadResult({
    required this.words, required this.chars, required this.sentences,
    required this.paragraphs, required this.syllables,
    required this.fleschScore, required this.difficulty,
  });
}
