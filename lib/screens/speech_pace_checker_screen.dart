import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class SpeechPaceCheckerScreen extends BaseToolScreen {
  const SpeechPaceCheckerScreen({super.key})
      : super(toolId: 'speech_pace_checker');
  @override
  State<SpeechPaceCheckerScreen> createState() =>
      _SpeechPaceCheckerScreenState();
}

class _SpeechPaceCheckerScreenState
    extends BaseToolScreenState<SpeechPaceCheckerScreen> {
  final _ctrl = TextEditingController();
  int _targetMinutes = 5;
  _SpeechResult? _result;

  // Standard speaking rates
  static const _speakingWpm = 130; // average conversational speaking WPM
  static const _presentationWpm = 110; // slightly slower for presentation clarity
  static const _podcaseWpm = 150; // podcasts tend to be faster

  void _analyze(String text) {
    if (text.trim().isEmpty) {
      setState(() => _result = null);
      return;
    }
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final chars = text.length;
    final sentences = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
    final avgSentLen = sentences > 0 ? words / sentences : 0.0;

    final convSec = (words / _speakingWpm * 60).round();
    final presSec = (words / _presentationWpm * 60).round();
    final podSec = (words / _podcaseWpm * 60).round();

    final targetSec = _targetMinutes * 60;
    final idealWords = (targetSec * _presentationWpm / 60).round();
    final wordDiff = idealWords - words;

    // Pace analysis for target time
    final paceRatio = words / idealWords;
    final _PaceStatus paceStatus;
    if (paceRatio < 0.75) {
      paceStatus = _PaceStatus('Too Short', Colors.orangeAccent,
          Icons.arrow_downward_outlined,
          '${idealWords - words} words aur add karo target time ke liye');
    } else if (paceRatio > 1.3) {
      paceStatus = _PaceStatus('Too Long', AppTheme.red,
          Icons.arrow_upward_outlined,
          '${words - idealWords} words kam karo target time ke liye');
    } else if (paceRatio > 1.1) {
      paceStatus = _PaceStatus('Slightly Long', Colors.yellowAccent,
          Icons.arrow_upward_outlined,
          'Thoda trim karo — ${words - idealWords} words zyada hain');
    } else if (paceRatio < 0.9) {
      paceStatus = _PaceStatus('Slightly Short', Colors.blueAccent,
          Icons.arrow_downward_outlined,
          '${idealWords - words} words aur chahiye');
    } else {
      paceStatus = _PaceStatus('Perfect!', Colors.greenAccent,
          Icons.check_circle_outline,
          'Speech bilkul ${_targetMinutes} minute ke liye sahi hai! 🎯');
    }

    // Sentence complexity
    final _ComplexityLevel complexity;
    if (avgSentLen < 10) {
      complexity = _ComplexityLevel('Simple', Colors.greenAccent,
          'Short sentences — audience ke liye acha hai');
    } else if (avgSentLen < 20) {
      complexity = _ComplexityLevel('Moderate', Colors.blueAccent,
          'Balanced sentence length — ideal for speeches');
    } else {
      complexity = _ComplexityLevel('Complex', Colors.orangeAccent,
          'Long sentences — bolte waqt break karo');
    }

    setState(() => _result = _SpeechResult(
      words: words,
      chars: chars,
      sentences: sentences,
      avgSentLen: avgSentLen,
      convSec: convSec,
      presSec: presSec,
      podSec: podSec,
      idealWords: idealWords,
      wordDiff: wordDiff,
      paceStatus: paceStatus,
      complexity: complexity,
    ));
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m < 60) return s == 0 ? '${m} min' : '${m}m ${s}s';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h} hr' : '${h}h ${rem}m';
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
        // Target duration
        _targetSlider(),
        const SizedBox(height: 16),

        // Text input
        TextField(
          controller: _ctrl,
          maxLines: 7,
          onChanged: _analyze,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Apni speech ya script yahan paste karo...',
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
          _paceStatusCard(_result!),
          const SizedBox(height: 16),
          _speakingTimesCard(_result!),
          const SizedBox(height: 16),
          _complexityCard(_result!),
          const SizedBox(height: 16),
          _statsGrid(_result!),
          const SizedBox(height: 16),
          _tipsCard(_result!),
        ] else
          _emptyHint(),
      ]),
    );
  }

  Widget _targetSlider() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Target Speech Duration',
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
            ),
            child: Text('$_targetMinutes min',
                style: GoogleFonts.orbitron(
                    color: AppTheme.purple, fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.purple,
            inactiveTrackColor: AppTheme.borderColor,
            thumbColor: AppTheme.purple,
            overlayColor: AppTheme.purple.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _targetMinutes.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            onChanged: (v) {
              setState(() => _targetMinutes = v.round());
              _analyze(_ctrl.text);
            },
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('1 min', style: GoogleFonts.rajdhani(
              color: AppTheme.textSecondary, fontSize: 11)),
          Text('60 min', style: GoogleFonts.rajdhani(
              color: AppTheme.textSecondary, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _paceStatusCard(_SpeechResult r) {
    final p = r.paceStatus;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.color.withOpacity(0.4), width: 1.5),
        gradient: LinearGradient(
          colors: [p.color.withOpacity(0.08), AppTheme.cardBg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(p.icon, color: p.color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pace Check ($_targetMinutes min)',
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 12)),
          Text(p.label,
              style: GoogleFonts.orbitron(
                  color: p.color, fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(p.suggestion,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 12,
                  height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _speakingTimesCard(_SpeechResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Estimated Speaking Time',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        _timeRow(Icons.mic_outlined, 'Presentation',
            _formatTime(r.presSec), '${_presentationWpm} WPM', AppTheme.purple),
        const SizedBox(height: 10),
        _timeRow(Icons.chat_outlined, 'Conversational',
            _formatTime(r.convSec), '${_speakingWpm} WPM', Colors.blueAccent),
        const SizedBox(height: 10),
        _timeRow(Icons.headphones_outlined, 'Podcast Style',
            _formatTime(r.podSec), '${_podcaseWpm} WPM', Colors.orangeAccent),
        const Divider(height: 20),
        Row(children: [
          Icon(Icons.flag_outlined, color: AppTheme.purple, size: 16),
          const SizedBox(width: 8),
          Text('Ideal words for $_targetMinutes min:',
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 12)),
          const Spacer(),
          Text('~${r.idealWords} words',
              style: GoogleFonts.orbitron(
                  color: AppTheme.purple, fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }

  Widget _timeRow(IconData icon, String label, String time, String rate, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.rajdhani(
                color: AppTheme.textPrimary, fontSize: 13)),
        Text(rate,
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 11)),
      ])),
      Text(time,
          style: GoogleFonts.orbitron(
              color: color, fontSize: 14, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _complexityCard(_SpeechResult r) {
    final c = r.complexity;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.account_tree_outlined, color: c.color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sentence Complexity: ${c.label}',
              style: GoogleFonts.rajdhani(
                  color: c.color, fontSize: 14, fontWeight: FontWeight.w600)),
          Text('Avg ${r.avgSentLen.toStringAsFixed(1)} words/sentence — ${c.desc}',
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 11, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _statsGrid(_SpeechResult r) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _statCard('Total Words', '${r.words}', Icons.text_fields_outlined, AppTheme.purple),
        _statCard('Characters', '${r.chars}', Icons.abc_outlined, Colors.blueAccent),
        _statCard('Sentences', '${r.sentences}', Icons.short_text_outlined, Colors.orangeAccent),
        _statCard('Word Diff',
            '${r.wordDiff >= 0 ? '+' : ''}${r.wordDiff}',
            Icons.compare_arrows_outlined,
            r.wordDiff.abs() < 50
                ? Colors.greenAccent
                : Colors.orangeAccent),
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
            color: color.withOpacity(0.15),
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

  Widget _tipsCard(_SpeechResult r) {
    final tips = <String>[];
    if (r.avgSentLen > 20) tips.add('Long sentences break karo — speaking mein short sentences better hain');
    if (r.wordDiff < -100) tips.add('Content add karo: examples, stories ya explanations');
    if (r.wordDiff > 100) tips.add('Unnecessary words remove karo — concise speech powerful hoti hai');
    if (r.sentences < 5) tips.add('Zyada sentences add karo structure ke liye');
    tips.add('Practice loud bolke karo — actual time differ ho sakta hai');
    tips.add('Pauses count hote hain — real time 10-20% zyada hoga');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.tips_and_updates_outlined,
              color: Colors.yellowAccent, size: 18),
          const SizedBox(width: 8),
          Text('Speech Tips',
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        ...tips.take(3).map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('• ', style: TextStyle(color: Colors.yellowAccent)),
            Expanded(child: Text(tip,
                style: GoogleFonts.rajdhani(
                    color: AppTheme.textSecondary, fontSize: 12,
                    height: 1.4))),
          ]),
        )),
      ]),
    );
  }

  Widget _emptyHint() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Icon(Icons.record_voice_over_outlined,
            color: AppTheme.textSecondary.withOpacity(0.4), size: 56),
        const SizedBox(height: 16),
        Text('Speech script paste karo',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 16)),
        const SizedBox(height: 6),
        Text('Target time ke hisaab se pace check hogi',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 13)),
      ]),
    );
  }
}

class _PaceStatus {
  final String label;
  final Color color;
  final IconData icon;
  final String suggestion;
  const _PaceStatus(this.label, this.color, this.icon, this.suggestion);
}

class _ComplexityLevel {
  final String label;
  final Color color;
  final String desc;
  const _ComplexityLevel(this.label, this.color, this.desc);
}

class _SpeechResult {
  final int words, chars, sentences, convSec, presSec, podSec;
  final int idealWords, wordDiff;
  final double avgSentLen;
  final _PaceStatus paceStatus;
  final _ComplexityLevel complexity;
  const _SpeechResult({
    required this.words, required this.chars, required this.sentences,
    required this.convSec, required this.presSec, required this.podSec,
    required this.idealWords, required this.wordDiff, required this.avgSentLen,
    required this.paceStatus, required this.complexity,
  });
}
