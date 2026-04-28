import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class UpsideDownTextScreen extends BaseToolScreen {
  const UpsideDownTextScreen({super.key}) : super(toolId: 'upside_down_text');
  @override
  State<UpsideDownTextScreen> createState() => _UpsideDownTextScreenState();
}

class _UpsideDownTextScreenState extends BaseToolScreenState<UpsideDownTextScreen> {
  final _inputCtrl = TextEditingController();
  String _output   = '';
  String _mode     = 'upsidedown';

  // Upside-down character map
  static const _udMap = {
    'a':'ɐ','b':'q','c':'ɔ','d':'p','e':'ǝ','f':'ɟ','g':'ƃ','h':'ɥ','i':'ᴉ','j':'ɾ',
    'k':'ʞ','l':'l','m':'ɯ','n':'u','o':'o','p':'d','q':'b','r':'ɹ','s':'s','t':'ʇ',
    'u':'n','v':'ʌ','w':'ʍ','x':'x','y':'ʎ','z':'z',
    'A':'∀','B':'ᗺ','C':'Ɔ','D':'ᗡ','E':'Ǝ','F':'Ⅎ','G':'פ','H':'H','I':'I','J':'ɾ',
    'K':'ʞ','L':'˥','M':'W','N':'N','O':'O','P':'Ԁ','Q':'Q','R':'ᴚ','S':'S','T':'┴',
    'U':'∩','V':'Λ','W':'M','X':'X','Y':'⅄','Z':'Z',
    '0':'0','1':'Ɩ','2':'ᄅ','3':'Ɛ','4':'ㄣ','5':'ϛ','6':'9','7':'ㄥ','8':'8','9':'6',
    '.':'˙',',':'\'','?':'¿','!':'¡','(':')',')':'(','{':'}','}':'{','[':']',']':'[',
    '"':'„','\'':',','<':'>','>':'<','_':'‾','&':'⅋','_':'‾',' ':' ',
  };

  // Zalgo chars for glitch effect
  static const _zalgoUp    = ['\u0300','\u0301','\u0302','\u0303','\u0304','\u0305','\u0306'];
  static const _zalgoMid   = ['\u0327','\u0328','\u0329','\u032a','\u032b'];
  static const _zalgoDown  = ['\u0316','\u0317','\u0318','\u0319','\u031a'];

  void _convert() {
    final text = _inputCtrl.text;
    if (text.isEmpty) { setError('Kuch likho!'); return; }
    setError(null);
    String result;
    switch (_mode) {
      case 'upsidedown':
        result = text.split('').map((c) => _udMap[c] ?? c).toList().reversed.join('');
        break;
      case 'mirror':
        result = text.split('').map((c) => _udMap[c] ?? c).join('');
        break;
      case 'reverse':
        result = text.split('').reversed.join('');
        break;
      case 'zalgo':
        final rng = DateTime.now().millisecondsSinceEpoch;
        result = text.split('').map((c) {
          if (c == ' ') return c;
          var r = c;
          r += _zalgoUp[(c.codeUnitAt(0) + rng) % _zalgoUp.length];
          r += _zalgoMid[(c.codeUnitAt(0) * 2 + rng) % _zalgoMid.length];
          r += _zalgoDown[(c.codeUnitAt(0) * 3 + rng) % _zalgoDown.length];
          return r;
        }).join('');
        break;
      case 'strikethrough':
        result = text.split('').map((c) => c == ' ' ? ' ' : '$c\u0336').join('');
        break;
      case 'underline':
        result = text.split('').map((c) => c == ' ' ? ' ' : '$c\u0332').join('');
        break;
      default: result = text;
    }
    setState(() => _output = result);
    showSnack('Done! ✅');
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
            hintText: 'Hello World',
            labelText: 'Input Text',
            suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() { _inputCtrl.clear(); _output = ''; })),
          ),
        ),
        const SizedBox(height: 14),

        Text('Effect', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
            fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _chip('upsidedown',    '🙃 Upside Down'),
          _chip('mirror',        '🪞 Mirror Flip'),
          _chip('reverse',       '⬅️ Reverse'),
          _chip('zalgo',         '👾 Glitch/Zalgo'),
          _chip('strikethrough', '~~Strike~~'),
          _chip('underline',     'U̲n̲d̲e̲r̲l̲i̲n̲e̲'),
        ]),
        const SizedBox(height: 16),

        GradientButton(label: 'Apply Effect', icon: Icons.auto_fix_high_outlined, onPressed: _convert),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Result', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
            Row(children: [
              IconButton(icon: const Icon(Icons.copy_outlined, size: 18), color: AppTheme.purple,
                  onPressed: () { Clipboard.setData(ClipboardData(text: _output)); showSnack('Copied!'); }),
              IconButton(icon: const Icon(Icons.share_outlined, size: 18), color: AppTheme.textSecondary,
                  onPressed: () => SharePlus.instance.share(ShareParams(text: _output))),
            ]),
          ]),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.purple.withOpacity(0.4))),
            child: SelectableText(_output, textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 20, height: 1.8)),
          ),
        ],
      ]),
    );
  }

  Widget _chip(String id, String label) {
    final sel = _mode == id;
    return GestureDetector(
      onTap: () => setState(() => _mode = id),
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: sel ? AppTheme.brandGradient : null,
          color: sel ? null : AppTheme.cardBg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor)),
        child: Text(label, style: GoogleFonts.rajdhani(
            color: sel ? Colors.white : AppTheme.textSecondary,
            fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
