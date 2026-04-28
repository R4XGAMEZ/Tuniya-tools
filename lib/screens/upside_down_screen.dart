import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class UpsideDownScreen extends BaseToolScreen {
  const UpsideDownScreen({super.key}) : super(toolId: 'upside_down_text');
  @override
  State<UpsideDownScreen> createState() => _UpsideDownScreenState();
}

class _UpsideDownScreenState extends BaseToolScreenState<UpsideDownScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String _mode = 'flip'; // flip, mirror, zalgo

  static const _flipMap = {
    'a': 'ɐ', 'b': 'q', 'c': 'ɔ', 'd': 'p', 'e': 'ǝ', 'f': 'ɟ',
    'g': 'ƃ', 'h': 'ɥ', 'i': 'ᴉ', 'j': 'ɾ', 'k': 'ʞ', 'l': 'l',
    'm': 'ɯ', 'n': 'u', 'o': 'o', 'p': 'd', 'q': 'b', 'r': 'ɹ',
    's': 's', 't': 'ʇ', 'u': 'n', 'v': 'ʌ', 'w': 'ʍ', 'x': 'x',
    'y': 'ʎ', 'z': 'z',
    'A': '∀', 'B': 'ᴮ', 'C': 'Ↄ', 'D': 'ᴰ', 'E': 'Ǝ', 'F': 'Ⅎ',
    'G': '⅁', 'H': 'H', 'I': 'I', 'J': 'ſ', 'K': 'ʞ', 'L': '⅂',
    'M': 'W', 'N': 'N', 'O': 'O', 'P': 'Ԁ', 'Q': 'Ό', 'R': 'ᴚ',
    'S': 'S', 'T': '⊥', 'U': '∩', 'V': '∧', 'W': 'M', 'X': 'X',
    'Y': '⅄', 'Z': 'Z',
    '0': '0', '1': 'Ɩ', '2': 'ᄅ', '3': 'Ɛ', '4': 'ㄣ', '5': 'ϛ',
    '6': '9', '7': 'ㄥ', '8': '8', '9': '6',
    '.': '˙', ',': "'", '?': '¿', '!': '¡', "'": ',', '(': ')',
    ')': '(', '[': ']', ']': '[', '{': '}', '}': '{',
    '&': '⅋', '_': '‾', ' ': ' ',
  };

  static const _zalgoTop = ['\u0300', '\u0301', '\u0302', '\u0303', '\u0304',
    '\u0305', '\u0306', '\u0307', '\u0308', '\u030a', '\u030b', '\u030d'];
  static const _zalgoBottom = ['\u0316', '\u0317', '\u0318', '\u0319', '\u031c',
    '\u031d', '\u031e', '\u031f', '\u0320', '\u0324', '\u0325', '\u0326'];

  void _convert() {
    final text = _inputCtrl.text;
    if (text.isEmpty) { setError('Kuch text likho!'); return; }
    setError(null);
    String result;
    switch (_mode) {
      case 'flip':
        result = text.split('').map((c) => _flipMap[c] ?? c).join('');
        result = result.split('').reversed.join(''); // flip order too
      case 'mirror':
        result = text.split('').map((c) => _flipMap[c] ?? c).join('');
      case 'zalgo':
        final rng = DateTime.now().millisecondsSinceEpoch;
        result = text.split('').map((c) {
          if (c == ' ') return c;
          final tops = (_zalgoTop..shuffle()).take(3).join('');
          final bots = (_zalgoBottom..shuffle()).take(3).join('');
          return '$tops$c$bots';
        }).join('');
      default:
        result = text;
    }
    setState(() => _output = result);
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
        TextField(
          controller: _inputCtrl,
          maxLines: 4,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Yahan text likho...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() { _inputCtrl.clear(); _output = ''; }),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Mode chips
        Wrap(spacing: 8, children: [
          _chip('flip',   '🙃 Upside Down (Flip)',    Icons.flip_outlined),
          _chip('mirror', '🪞 Mirror Only',            Icons.flip_camera_android_outlined),
          _chip('zalgo',  '😈 Zalgo (Creepy)',         Icons.warning_amber_outlined),
        ]),
        const SizedBox(height: 16),

        GradientButton(
          label: 'Transform Karo!',
          icon: Icons.auto_fix_high_outlined,
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
                showSnack('Copy ho gaya! Share karo 🎉');
              },
            ),
          ]),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4)),
            ),
            child: SelectableText(
              _output,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 16, height: 1.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 WhatsApp / Instagram pe paste karke dosto ko confuse karo!',
            style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ]),
    );
  }

  Widget _chip(String id, String label, IconData icon) {
    final sel = _mode == id;
    return GestureDetector(
      onTap: () => setState(() { _mode = id; _output = ''; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: sel ? AppTheme.brandGradient : null,
          color: sel ? null : AppTheme.cardBg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: sel ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.rajdhani(
              color: sel ? Colors.white : AppTheme.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
