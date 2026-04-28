import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class SimpleParaphraseScreen extends BaseToolScreen {
  const SimpleParaphraseScreen({super.key})
      : super(toolId: 'simple_paraphrase');
  @override
  State<SimpleParaphraseScreen> createState() => _SimpleParaphraseScreenState();
}

class _SimpleParaphraseScreenState
    extends BaseToolScreenState<SimpleParaphraseScreen> {
  final _inputCtrl = TextEditingController();
  final _outputCtrl = TextEditingController();
  int _modeIndex = 0;
  bool _processing = false;

  static const _modes = [
    _ParaMode('Standard', Icons.auto_fix_normal_outlined, Colors.blueAccent,
        'Original meaning rakho, words badlo'),
    _ParaMode('Formal', Icons.business_center_outlined, Color(0xFF4A90D9),
        'Professional aur serious tone'),
    _ParaMode('Simple', Icons.child_care_outlined, Color(0xFF50C878),
        'Simple words, easy to understand'),
    _ParaMode('Creative', Icons.auto_awesome_outlined, Color(0xFFFFD700),
        'Expressive aur engaging style'),
  ];

  // Synonym maps for offline paraphrasing
  static const _synonyms = {
    'good': ['excellent', 'great', 'wonderful', 'superb', 'outstanding'],
    'bad': ['poor', 'terrible', 'awful', 'dreadful', 'inferior'],
    'big': ['large', 'huge', 'enormous', 'massive', 'substantial'],
    'small': ['tiny', 'little', 'compact', 'minimal', 'slight'],
    'important': ['crucial', 'significant', 'essential', 'vital', 'critical'],
    'show': ['demonstrate', 'reveal', 'display', 'illustrate', 'present'],
    'use': ['utilize', 'employ', 'apply', 'implement', 'leverage'],
    'make': ['create', 'produce', 'generate', 'develop', 'craft'],
    'get': ['obtain', 'acquire', 'receive', 'gain', 'secure'],
    'say': ['state', 'mention', 'express', 'indicate', 'convey'],
    'think': ['believe', 'consider', 'assume', 'suppose', 'reflect'],
    'help': ['assist', 'support', 'aid', 'facilitate', 'enable'],
    'need': ['require', 'demand', 'necessitate', 'seek', 'desire'],
    'new': ['recent', 'novel', 'modern', 'fresh', 'current'],
    'old': ['ancient', 'traditional', 'established', 'classic', 'historic'],
    'fast': ['rapid', 'swift', 'quick', 'efficient', 'speedy'],
    'easy': ['simple', 'straightforward', 'effortless', 'convenient', 'accessible'],
    'hard': ['difficult', 'challenging', 'complex', 'demanding', 'tough'],
    'begin': ['start', 'initiate', 'commence', 'launch', 'undertake'],
    'end': ['conclude', 'finish', 'complete', 'terminate', 'finalize'],
    'also': ['additionally', 'furthermore', 'moreover', 'besides', 'likewise'],
    'but': ['however', 'nevertheless', 'yet', 'although', 'despite this'],
    'so': ['therefore', 'consequently', 'thus', 'as a result', 'hence'],
    'very': ['extremely', 'remarkably', 'exceptionally', 'particularly', 'notably'],
    'many': ['numerous', 'several', 'various', 'multiple', 'countless'],
    'often': ['frequently', 'regularly', 'commonly', 'typically', 'repeatedly'],
  };

  static const _formalConnectors = [
    'Furthermore,', 'Additionally,', 'Moreover,', 'Consequently,',
    'Therefore,', 'In addition,', 'As a result,',
  ];

  static const _simpleConnectors = [
    'Also,', 'Plus,', 'And so,', 'Because of this,', 'This means,',
  ];

  void _paraphrase() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) {
      showSnack('Pehle kuch text enter karo!', isError: true);
      return;
    }
    setState(() => _processing = true);

    // Simulate processing delay for UX
    Future.delayed(const Duration(milliseconds: 600), () {
      final result = _doParaphrase(text, _modeIndex);
      setState(() {
        _outputCtrl.text = result;
        _processing = false;
      });
    });
  }

  String _doParaphrase(String text, int mode) {
    // Split into sentences
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final result = sentences.map((sentence) {
      return _transformSentence(sentence, mode);
    }).join(' ');

    return result;
  }

  String _transformSentence(String sentence, int mode) {
    String s = sentence;

    // Replace synonyms based on mode
    final words = s.split(' ');
    final transformed = words.map((word) {
      final clean = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      if (_synonyms.containsKey(clean)) {
        final list = _synonyms[clean]!;
        final idx = mode < list.length ? mode : list.length - 1;
        // Preserve capitalization
        final replacement = list[idx];
        if (word[0] == word[0].toUpperCase() && word[0] != word[0].toLowerCase()) {
          return replacement[0].toUpperCase() + replacement.substring(1);
        }
        return replacement;
      }
      return word;
    }).toList();

    s = transformed.join(' ');

    // Mode-specific transformations
    switch (mode) {
      case 1: // Formal
        s = _makeFormal(s);
        break;
      case 2: // Simple
        s = _makeSimple(s);
        break;
      case 3: // Creative
        s = _makeCreative(s);
        break;
    }

    return s;
  }

  String _makeFormal(String s) {
    return s
        .replaceAll("don't", 'do not')
        .replaceAll("can't", 'cannot')
        .replaceAll("won't", 'will not')
        .replaceAll("it's", 'it is')
        .replaceAll("they're", 'they are')
        .replaceAll("we're", 'we are')
        .replaceAll("I'm", 'I am')
        .replaceAll("gonna", 'going to')
        .replaceAll("wanna", 'want to')
        .replaceAll("gotta", 'have to');
  }

  String _makeSimple(String s) {
    return s
        .replaceAll('utilize', 'use')
        .replaceAll('demonstrate', 'show')
        .replaceAll('facilitate', 'help')
        .replaceAll('implement', 'use')
        .replaceAll('consequently', 'so')
        .replaceAll('furthermore', 'also')
        .replaceAll('nevertheless', 'but')
        .replaceAll('subsequently', 'then')
        .replaceAll('approximately', 'about')
        .replaceAll('sufficient', 'enough');
  }

  String _makeCreative(String s) {
    // Add some flair
    s = s.replaceAll('very ', 'incredibly ')
         .replaceAll('quite ', 'remarkably ')
         .replaceAll('good', 'exceptional')
         .replaceAll('bad', 'disastrous');
    return s;
  }


  @override
  void dispose() {
    _inputCtrl.dispose();
    _outputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Mode selector
        _modeSelector(),
        const SizedBox(height: 16),

        // Input
        _label('Original Text'),
        const SizedBox(height: 8),
        TextField(
          controller: _inputCtrl,
          maxLines: 6,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Yahan text paste karo jo paraphrase karni ho...',
            alignLabelWithHint: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _inputCtrl.clear();
                _outputCtrl.clear();
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Paraphrase button
        ElevatedButton.icon(
          onPressed: _processing ? null : _paraphrase,
          icon: _processing
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.auto_fix_high_outlined, size: 18),
          label: Text(_processing ? 'Paraphrasing...' : 'Paraphrase Karo',
              style: GoogleFonts.rajdhani(fontSize: 15,
                  fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: _modes[_modeIndex].color.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),

        // Output
        if (_outputCtrl.text.isNotEmpty) ...[
          Row(children: [
            _label('Paraphrased Text'),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _outputCtrl.text));
                showSnack('Copied!');
              },
              icon: const Icon(Icons.copy_outlined, size: 16),
              label: Text('Copy', style: GoogleFonts.rajdhani(fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _modes[_modeIndex].color.withOpacity(0.4)),
            ),
            child: Text(
              _outputCtrl.text,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          _diffStats(),
        ],

        // Info card
        _infoCard(),
      ]),
    );
  }

  Widget _modeSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Paraphrase Style',
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3.2,
          children: List.generate(_modes.length, (i) {
            final m = _modes[i];
            final selected = _modeIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _modeIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? m.color.withOpacity(0.15) : AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: selected ? m.color : AppTheme.borderColor),
                ),
                child: Row(children: [
                  Icon(m.icon, color: selected ? m.color : AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(m.label,
                      style: GoogleFonts.rajdhani(
                          color: selected ? m.color : AppTheme.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(_modes[_modeIndex].desc,
            style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 11)),
      ]),
    );
  }

  Widget _diffStats() {
    final orig = _inputCtrl.text.trim().split(RegExp(r'\s+')).length;
    final para = _outputCtrl.text.trim().split(RegExp(r'\s+')).length;
    final diff = para - orig;
    final pct = orig > 0 ? ((para / orig) * 100).toInt() : 100;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _miniStat2('Original', '$orig words', AppTheme.textSecondary),
        Container(width: 1, height: 30, color: AppTheme.borderColor),
        _miniStat2('Result', '$para words', AppTheme.purple),
        Container(width: 1, height: 30, color: AppTheme.borderColor),
        _miniStat2('Change',
            '${diff >= 0 ? '+' : ''}$diff ($pct%)',
            diff >= 0 ? Colors.greenAccent : Colors.orangeAccent),
      ]),
    );
  }

  Widget _miniStat2(String label, String value, Color color) {
    return Column(children: [
      Text(label,
          style: GoogleFonts.rajdhani(
              color: AppTheme.textSecondary, fontSize: 11)),
      Text(value,
          style: GoogleFonts.orbitron(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, color: AppTheme.purple, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(
          'Yeh tool offline kaam karta hai — synonym replacement aur style changes use karta hai. '
          'Perfect results ke liye output ko manually review karo.',
          style: GoogleFonts.rajdhani(
              color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
        )),
      ]),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: GoogleFonts.rajdhani(
            color: AppTheme.textSecondary, fontSize: 13,
            fontWeight: FontWeight.w600));
  }
}

class _ParaMode {
  final String label;
  final IconData icon;
  final Color color;
  final String desc;
  const _ParaMode(this.label, this.icon, this.color, this.desc);
}
