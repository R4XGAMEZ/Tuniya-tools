import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class ColorPickerScreen extends BaseToolScreen {
  const ColorPickerScreen({super.key}) : super(toolId: 'color_picker');
  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends BaseToolScreenState<ColorPickerScreen> {
  double _r = 99, _g = 102, _b = 241; // default indigo
  double _h = 0, _s = 0, _l = 0;
  final _hexCtrl = TextEditingController();
  List<Color> _savedColors = [];
  bool _inputMode = false; // false=RGB sliders, true=HEX input

  Color get _color => Color.fromRGBO(_r.round(), _g.round(), _b.round(), 1);

  @override
  void initState() {
    super.initState();
    _updateHSL();
    _updateHex();
  }

  void _updateHSL() {
    final r = _r / 255, g = _g / 255, b = _b / 255;
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    _l = (max + min) / 2;
    if (max == min) { _h = 0; _s = 0; return; }
    final d = max - min;
    _s = _l > 0.5 ? d / (2 - max - min) : d / (max + min);
    if (max == r) _h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
    else if (max == g) _h = ((b - r) / d + 2) / 6;
    else _h = ((r - g) / d + 4) / 6;
    _h *= 360;
  }

  void _updateHex() {
    _hexCtrl.text = '#${_r.round().toRadixString(16).padLeft(2,'0')}'
        '${_g.round().toRadixString(16).padLeft(2,'0')}'
        '${_b.round().toRadixString(16).padLeft(2,'0')}';
  }

  void _fromHex(String hex) {
    hex = hex.replaceAll('#', '').trim();
    if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join('');
    if (hex.length != 6) return;
    try {
      setState(() {
        _r = int.parse(hex.substring(0,2), radix: 16).toDouble();
        _g = int.parse(hex.substring(2,4), radix: 16).toDouble();
        _b = int.parse(hex.substring(4,6), radix: 16).toDouble();
        _updateHSL();
      });
    } catch (_) {}
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnack('Copied: $text');
  }

  String get _hex => _hexCtrl.text;
  String get _rgb => 'rgb(${_r.round()}, ${_g.round()}, ${_b.round()})';
  String get _hsl => 'hsl(${_h.round()}, ${(_s*100).round()}%, ${(_l*100).round()}%)';
  String get _cssVar => '--color: ${_hexCtrl.text};';


  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // Color preview
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Center(
            child: Text(_hexCtrl.text.toUpperCase(),
                style: GoogleFonts.orbitron(
                  color: _l > 0.5 ? Colors.black87 : Colors.white,
                  fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2,
                )),
          ),
        ),
        const SizedBox(height: 16),

        // RGB Sliders
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor)),
          child: Column(children: [
            _slider('R', _r, Colors.red,   (v) => setState(() { _r = v; _updateHSL(); _updateHex(); })),
            _slider('G', _g, Colors.green, (v) => setState(() { _g = v; _updateHSL(); _updateHex(); })),
            _slider('B', _b, Colors.blue,  (v) => setState(() { _b = v; _updateHSL(); _updateHex(); })),
          ]),
        ),
        const SizedBox(height: 12),

        // HEX input
        TextField(
          controller: _hexCtrl,
          onChanged: _fromHex,
          style: GoogleFonts.robotoMono(color: AppTheme.textPrimary, fontSize: 15, letterSpacing: 2),
          decoration: InputDecoration(
            labelText: 'HEX Code',
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              width: 32, height: 32,
              decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.borderColor)),
            ),
            suffixIcon: IconButton(icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppTheme.purple, onPressed: () => _copy(_hex)),
          ),
        ),
        const SizedBox(height: 16),

        // Color values
        Text('Color Values', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
            fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...[
          ('HEX', _hex),
          ('RGB', _rgb),
          ('HSL', _hsl),
          ('CSS Var', _cssVar),
        ].map((e) => _valueRow(e.$1, e.$2)),

        const SizedBox(height: 16),

        // Palette row
        _paletteSection(),

        const SizedBox(height: 16),

        // Saved colors
        if (_savedColors.isNotEmpty) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Saved Colors', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
            TextButton(onPressed: () => setState(() => _savedColors.clear()),
                child: Text('Clear', style: GoogleFonts.rajdhani(color: AppTheme.red))),
          ]),
          Wrap(spacing: 8, runSpacing: 8,
            children: _savedColors.map((c) => GestureDetector(
              onTap: () => setState(() {
                _r = c.red.toDouble(); _g = c.green.toDouble(); _b = c.blue.toDouble();
                _updateHSL(); _updateHex();
              }),
              child: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderColor))),
            )).toList(),
          ),
        ],

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => setState(() => _savedColors.add(_color)),
          icon: const Icon(Icons.bookmark_add_outlined, size: 18),
          label: Text('Save Current Color', style: GoogleFonts.rajdhani()),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple,
              side: BorderSide(color: AppTheme.purple.withOpacity(0.5)),
              padding: const EdgeInsets.all(14)),
        ),
      ]),
    );
  }

  Widget _slider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Row(children: [
      SizedBox(width: 14, child: Text(label,
          style: GoogleFonts.rajdhani(color: color, fontSize: 13, fontWeight: FontWeight.bold))),
      Expanded(child: SliderTheme(
        data: SliderTheme.of(context).copyWith(activeTrackColor: color,
            thumbColor: color, inactiveTrackColor: color.withOpacity(0.2)),
        child: Slider(value: value, min: 0, max: 255, divisions: 255,
            onChanged: onChanged),
      )),
      SizedBox(width: 32, child: Text('${value.round()}',
          style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 11),
          textAlign: TextAlign.right)),
    ]);
  }

  Widget _valueRow(String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor)),
    child: Row(children: [
      SizedBox(width: 60, child: Text(label,
          style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w600))),
      Expanded(child: Text(value,
          style: GoogleFonts.robotoMono(color: AppTheme.textPrimary, fontSize: 12))),
      IconButton(icon: const Icon(Icons.copy_outlined, size: 16), color: AppTheme.purple,
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          onPressed: () => _copy(value)),
    ]),
  );

  Widget _paletteSection() {
    // Generate shades
    final shades = List.generate(9, (i) {
      final t = (i + 1) / 10;
      return Color.fromRGBO(
        (_r + (255 - _r) * (1 - t)).round().clamp(0,255),
        (_g + (255 - _g) * (1 - t)).round().clamp(0,255),
        (_b + (255 - _b) * (1 - t)).round().clamp(0,255), 1);
    });
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Shades', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
          fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Row(children: shades.map((c) => Expanded(child: GestureDetector(
        onTap: () => setState(() {
          _r = c.red.toDouble(); _g = c.green.toDouble(); _b = c.blue.toDouble();
          _updateHSL(); _updateHex();
        }),
        child: Container(height: 40,
          decoration: BoxDecoration(color: c,
              borderRadius: BorderRadius.horizontal(
                left: shades.first == c ? const Radius.circular(8) : Radius.zero,
                right: shades.last == c ? const Radius.circular(8) : Radius.zero))),
      ))).toList()),
    ]);
  }
}
