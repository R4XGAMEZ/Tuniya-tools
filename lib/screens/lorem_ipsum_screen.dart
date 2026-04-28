import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class LoremIpsumScreen extends BaseToolScreen {
  const LoremIpsumScreen({super.key}) : super(toolId: 'lorem_ipsum');
  @override
  State<LoremIpsumScreen> createState() => _LoremIpsumScreenState();
}

class _LoremIpsumScreenState extends BaseToolScreenState<LoremIpsumScreen> {
  String _output    = '';
  int    _count     = 3;
  String _unit      = 'paragraphs'; // paragraphs | sentences | words
  bool   _startWithLorem = true;

  static const _words = [
    'lorem','ipsum','dolor','sit','amet','consectetur','adipiscing','elit',
    'sed','do','eiusmod','tempor','incididunt','ut','labore','et','dolore',
    'magna','aliqua','enim','ad','minim','veniam','quis','nostrud','exercitation',
    'ullamco','laboris','nisi','aliquip','ex','ea','commodo','consequat','duis',
    'aute','irure','in','reprehenderit','voluptate','velit','esse','cillum',
    'fugiat','nulla','pariatur','excepteur','sint','occaecat','cupidatat','non',
    'proident','sunt','culpa','qui','officia','deserunt','mollit','anim','id',
    'est','laborum','perspiciatis','unde','omnis','iste','natus','error',
    'accusantium','doloremque','laudantium','totam','rem','aperiam','eaque',
    'ipsa','quae','ab','illo','inventore','veritatis','architecto','beatae',
    'vitae','dicta','explicabo','nemo','voluptatem','quia','voluptas','aspernatur',
    'aut','odit','fugit','magni','porro','quisquam','qui','dolorem','adipisci',
    'numquam','eius','modi','tempora','incidunt','magnam','quaerat',
  ];

  final _rng = Random();

  String _word() => _words[_rng.nextInt(_words.length)];

  String _sentence() {
    final len = 8 + _rng.nextInt(10);
    final words = List.generate(len, (_) => _word());
    return words[0][0].toUpperCase() + words[0].substring(1) +
        ' ' + words.skip(1).join(' ') + '.';
  }

  String _paragraph() {
    final sentCount = 3 + _rng.nextInt(4);
    return List.generate(sentCount, (_) => _sentence()).join(' ');
  }

  void _generate() {
    setError(null);
    String result;
    switch (_unit) {
      case 'words':
        final words = List.generate(_count, (_) => _word());
        if (_startWithLorem && _count >= 2) { words[0] = 'Lorem'; words[1] = 'ipsum'; }
        result = words.join(' ');
        break;
      case 'sentences':
        final sents = List.generate(_count, (_) => _sentence());
        if (_startWithLorem) sents[0] = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
        result = sents.join('\n');
        break;
      default: // paragraphs
        final paras = List.generate(_count, (_) => _paragraph());
        if (_startWithLorem) {
          paras[0] = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';
        }
        result = paras.join('\n\n');
    }
    setState(() => _output = result);
    showSnack('Generated! ✅');
  }

  String get _unitLabel {
    switch (_unit) {
      case 'words':     return 'Words';
      case 'sentences': return 'Sentences';
      default:          return 'Paragraphs';
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // Unit selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(children: [
            _unitBtn('paragraphs', 'Paragraphs'),
            _unitBtn('sentences',  'Sentences'),
            _unitBtn('words',      'Words'),
          ]),
        ),
        const SizedBox(height: 20),

        // Count slider
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Kitne $_unitLabel?',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
                child: Text('$_count',
                    style: GoogleFonts.orbitron(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ]),
            Slider(
              value: _count.toDouble(),
              min: 1,
              max: _unit == 'words' ? 500 : _unit == 'sentences' ? 30 : 10,
              divisions: _unit == 'words' ? 50 : _unit == 'sentences' ? 29 : 9,
              activeColor: AppTheme.purple,
              onChanged: (v) => setState(() => _count = v.round()),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Options
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: SwitchListTile(
            value: _startWithLorem,
            onChanged: (v) => setState(() => _startWithLorem = v),
            title: Text('"Lorem ipsum..." se start karo',
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
            activeColor: AppTheme.purple,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),

        GradientButton(
          label: 'Generate Karo',
          icon: Icons.auto_awesome_outlined,
          onPressed: _generate,
        ),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Generated Text',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Row(children: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppTheme.purple,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _output));
                  showSnack('Copy ho gaya!');
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppTheme.textSecondary,
                onPressed: () => Share.share(_output),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_outlined, size: 18),
                color: AppTheme.textSecondary,
                onPressed: _generate,
              ),
            ]),
          ]),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.purple.withValues(alpha: 0.3)),
            ),
            child: SelectableText(
              _output,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.7),
            ),
          ),
          const SizedBox(height: 10),
          // Stats
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _chip('${_output.split(RegExp(r'\s+')).length} words'),
            const SizedBox(width: 8),
            _chip('${_output.length} chars'),
          ]),
        ],
      ]),
    );
  }

  Widget _unitBtn(String id, String label) {
    final sel = _unit == id;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() { _unit = id; _count = id == 'words' ? 50 : 3; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: sel ? AppTheme.brandGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
                color: sel ? Colors.white : AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    ));
  }

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: AppTheme.purple.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.purple.withValues(alpha: 0.3)),
    ),
    child: Text(label,
        style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 12,
            fontWeight: FontWeight.w600)),
  );
}
