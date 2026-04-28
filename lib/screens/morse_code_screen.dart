import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class MorseCodeScreen extends BaseToolScreen {
  const MorseCodeScreen({super.key}) : super(toolId: 'morse_code');
  @override
  State<MorseCodeScreen> createState() => _MorseCodeScreenState();
}

class _MorseCodeScreenState extends BaseToolScreenState<MorseCodeScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  bool _toMorse = true; // true = Text→Morse, false = Morse→Text

  static const _map = {
    'A': '.-',   'B': '-...',  'C': '-.-.',  'D': '-..',
    'E': '.',    'F': '..-.',  'G': '--.',   'H': '....',
    'I': '..',   'J': '.---',  'K': '-.-',   'L': '.-..',
    'M': '--',   'N': '-.',    'O': '---',   'P': '.--.',
    'Q': '--.-', 'R': '.-.',   'S': '...',   'T': '-',
    'U': '..-',  'V': '...-',  'W': '.--',   'X': '-..-',
    'Y': '-.--', 'Z': '--..',
    '0': '-----','1': '.----','2': '..---','3': '...--',
    '4': '....-','5': '.....','6': '-....','7': '--...',
    '8': '---..',  '9': '----.',
    '.': '.-.-.-',',': '--..--','?': '..--..','!': '-.-.--',
    ':': '---...', ';': '-.-.-.', '-': '-....-', '/': '-..-.',
    '@': '.--.-.', "'": '.----.','(': '-.--.',  ')': '-.--.-',
  };

  void _convert() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) { setError('Kuch input dalo!'); return; }
    setError(null);
    if (_toMorse) {
      final result = text.toUpperCase().split('').map((c) {
        if (c == ' ') return '/';
        return _map[c] ?? '?';
      }).join(' ');
      setState(() => _output = result);
    } else {
      final reverseMap = {for (var e in _map.entries) e.value: e.key};
      final words = text.split(' / ');
      final decoded = words.map((word) {
        return word.split(' ').map((code) {
          if (code.isEmpty) return '';
          return reverseMap[code] ?? '?';
        }).join('');
      }).join(' ');
      setState(() => _output = decoded);
    }
  }


  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Mode toggle
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(children: [
            _ModeBtn('Text → Morse', _toMorse, () => setState(() { _toMorse = true; _output = ''; })),
            _ModeBtn('Morse → Text', !_toMorse, () => setState(() { _toMorse = false; _output = ''; })),
          ]),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _inputCtrl,
          maxLines: 5,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14,
              letterSpacing: _toMorse ? 0 : 2),
          decoration: InputDecoration(
            hintText: _toMorse
                ? 'Yahan text likho... (e.g. HELLO)'
                : 'Morse code paste karo... (e.g. .... . .-.. .-.. ---)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() { _inputCtrl.clear(); _output = ''; }),
            ),
          ),
        ),
        const SizedBox(height: 14),

        GradientButton(
          label: _toMorse ? 'Morse mein Convert Karo' : 'Text mein Decode Karo',
          icon: Icons.radio_outlined,
          onPressed: _convert,
        ),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Result',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 18),
              color: AppTheme.purple,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _output));
                showSnack('Copy ho gaya!');
              },
            ),
          ]),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
            ),
            child: SelectableText(
              _output,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 15,
                  letterSpacing: _toMorse ? 2 : 0, height: 1.6),
            ),
          ),
        ],

        const SizedBox(height: 20),
        // Quick reference card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quick Reference',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10, runSpacing: 6,
              children: _map.entries.take(26).map((e) => Text(
                '${e.key}: ${e.value}',
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary.withOpacity(0.7),
                    fontSize: 11, letterSpacing: 1),
              )).toList(),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _ModeBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active ? AppTheme.brandGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                  color: active ? Colors.white : AppTheme.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
