import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class TextToneDetectorScreen extends BaseToolScreen {
  const TextToneDetectorScreen({super.key})
      : super(toolId: 'text_tone_detector');
  @override
  State<TextToneDetectorScreen> createState() =>
      _TextToneDetectorScreenState();
}

class _TextToneDetectorScreenState
    extends BaseToolScreenState<TextToneDetectorScreen> {
  final _ctrl = TextEditingController();
  _ToneResult? _result;

  static const _tones = {
    'Formal': {
      'keywords': ['therefore', 'moreover', 'consequently', 'furthermore',
        'regarding', 'hereby', 'pursuant', 'notwithstanding', 'accordingly',
        'henceforth', 'whereas', 'aforementioned', 'thus', 'hence'],
      'color': Color(0xFF4A90D9),
      'icon': Icons.business_center_outlined,
      'desc': 'Professional aur official tone — reports, emails ke liye perfect.',
    },
    'Casual': {
      'keywords': ['hey', 'gonna', 'wanna', 'kinda', 'stuff', 'cool', 'awesome',
        'yeah', 'nope', 'btw', 'lol', 'omg', 'tbh', 'lmao', 'dude', 'bro'],
      'color': Color(0xFF50C878),
      'icon': Icons.chat_bubble_outline,
      'desc': 'Friendly aur relaxed tone — dosto ke messages jaisa.',
    },
    'Persuasive': {
      'keywords': ['must', 'should', 'need', 'important', 'critical', 'essential',
        'urgent', 'immediately', 'now', 'best', 'proven', 'guaranteed', 'only',
        'limited', 'exclusive', 'believe', 'consider'],
      'color': Color(0xFFFF8C00),
      'icon': Icons.campaign_outlined,
      'desc': 'Convincing tone — marketing aur arguments ke liye.',
    },
    'Negative': {
      'keywords': ['bad', 'terrible', 'awful', 'horrible', 'worst', 'hate',
        'disgusting', 'pathetic', 'useless', 'waste', 'fail', 'failure',
        'stupid', 'idiot', 'wrong', 'never', 'impossible'],
      'color': Color(0xFFE8003D),
      'icon': Icons.sentiment_very_dissatisfied_outlined,
      'desc': 'Negative ya critical tone — frustration ya complaint.',
    },
    'Positive': {
      'keywords': ['great', 'excellent', 'wonderful', 'amazing', 'fantastic',
        'love', 'happy', 'joy', 'perfect', 'brilliant', 'outstanding',
        'success', 'win', 'celebrate', 'grateful', 'thankful', 'glad'],
      'color': Color(0xFFFFD700),
      'icon': Icons.sentiment_very_satisfied_outlined,
      'desc': 'Upbeat aur enthusiastic tone — positivity vibes.',
    },
    'Informative': {
      'keywords': ['according', 'research', 'study', 'data', 'report', 'analysis',
        'findings', 'evidence', 'statistics', 'percent', 'shows', 'indicates',
        'reveals', 'suggests', 'confirms', 'demonstrates'],
      'color': Color(0xFF7B2FBE),
      'icon': Icons.info_outline,
      'desc': 'Factual aur educational tone — knowledge share ke liye.',
    },
  };

  void _analyze(String text) {
    if (text.trim().isEmpty) {
      setState(() => _result = null);
      return;
    }

    final lower = text.toLowerCase();
    final wordList = lower.split(RegExp(r'\s+'));
    final scores = <String, double>{};

    for (final tone in _tones.entries) {
      final keywords = tone.value['keywords'] as List<String>;
      int matches = 0;
      for (final kw in keywords) {
        if (wordList.contains(kw)) matches++;
      }
      scores[tone.key] = matches / keywords.length;
    }

    // Sentence analysis
    final exclamations = '!'.allMatches(text).length;
    final questions = '?'.allMatches(text).length;
    final avgWordLen = wordList.isEmpty
        ? 0.0
        : wordList.map((w) => w.length).reduce((a, b) => a + b) /
            wordList.length;

    // Boost scores based on punctuation
    if (exclamations > 2) scores['Positive'] = (scores['Positive'] ?? 0) + 0.1;
    if (exclamations > 2) scores['Persuasive'] = (scores['Persuasive'] ?? 0) + 0.05;
    if (questions > 2) scores['Casual'] = (scores['Casual'] ?? 0) + 0.05;
    if (avgWordLen > 7) scores['Formal'] = (scores['Formal'] ?? 0) + 0.1;
    if (avgWordLen < 5) scores['Casual'] = (scores['Casual'] ?? 0) + 0.08;

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Normalize top 3
    final maxScore = sorted.first.value;
    final topTones = sorted.take(3).map((e) {
      final pct = maxScore > 0 ? (e.value / maxScore) : 0.0;
      return _ToneScore(
        name: e.key,
        score: pct.clamp(0.0, 1.0),
        info: _tones[e.key]!,
      );
    }).toList();

    final wordCount = wordList.where((w) => w.isNotEmpty).length;
    final sentenceCount = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;

    setState(() => _result = _ToneResult(
      primaryTone: sorted.first.key,
      tones: topTones,
      wordCount: wordCount,
      sentenceCount: sentenceCount,
      avgWordLen: avgWordLen,
      exclamations: exclamations,
      questions: questions,
    ));
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
        // Input
        TextField(
          controller: _ctrl,
          maxLines: 7,
          onChanged: _analyze,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Yahan apna text paste karo — tone detect hogi...',
            alignLabelWithHint: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () { _ctrl.clear(); _analyze(''); },
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (_result != null) ...[
          // Primary tone badge
          _primaryToneCard(_result!),
          const SizedBox(height: 16),

          // Tone bars
          _toneBarsCard(_result!),
          const SizedBox(height: 16),

          // Text stats
          _statsCard(_result!),
        ] else
          _emptyState(),
      ]),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Icon(Icons.psychology_outlined,
            color: AppTheme.textSecondary.withValues(alpha: 0.4), size: 56),
        const SizedBox(height: 16),
        Text('Text likhna shuru karo',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 16)),
        const SizedBox(height: 6),
        Text('AI aapke writing ka mood detect karega',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 13)),
      ]),
    );
  }

  Widget _primaryToneCard(_ToneResult r) {
    final info = _tones[r.primaryTone]!;
    final color = info['color'] as Color;
    final icon = info['icon'] as IconData;
    final desc = info['desc'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.08), AppTheme.cardBg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Primary Tone',
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 12,
                  fontWeight: FontWeight.w600)),
          Text(r.primaryTone,
              style: GoogleFonts.orbitron(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _toneBarsCard(_ToneResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tone Breakdown',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        ...r.tones.map((t) {
          final color = _tones[t.name]!['color'] as Color;
          final icon = _tones[t.name]!['icon'] as IconData;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(t.name,
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.textPrimary, fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${(t.score * 100).toInt()}%',
                    style: GoogleFonts.orbitron(
                        color: color, fontSize: 12)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: t.score,
                  minHeight: 8,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _statsCard(_ToneResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Text Analysis',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: [
            _miniStat('Words', '${r.wordCount}', Icons.text_fields_outlined, AppTheme.purple),
            _miniStat('Sentences', '${r.sentenceCount}', Icons.short_text_outlined, Colors.blueAccent),
            _miniStat('Avg Word Len', '${r.avgWordLen.toStringAsFixed(1)}', Icons.format_size_outlined, Colors.orangeAccent),
            _miniStat('Exclamations', '${r.exclamations}', Icons.priority_high_outlined, Colors.greenAccent),
          ],
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value,
              style: GoogleFonts.orbitron(
                  color: AppTheme.textPrimary, fontSize: 13,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 10)),
        ])),
      ]),
    );
  }
}

class _ToneScore {
  final String name;
  final double score;
  final Map<String, dynamic> info;
  const _ToneScore({required this.name, required this.score, required this.info});
}

class _ToneResult {
  final String primaryTone;
  final List<_ToneScore> tones;
  final int wordCount;
  final int sentenceCount;
  final double avgWordLen;
  final int exclamations;
  final int questions;
  const _ToneResult({
    required this.primaryTone, required this.tones, required this.wordCount,
    required this.sentenceCount, required this.avgWordLen,
    required this.exclamations, required this.questions,
  });
}
