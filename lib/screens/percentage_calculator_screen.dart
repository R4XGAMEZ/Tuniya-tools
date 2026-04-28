import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class PercentageCalculatorScreen extends BaseToolScreen {
  const PercentageCalculatorScreen({super.key}) : super(toolId: 'percentage_calculator');
  @override
  State<PercentageCalculatorScreen> createState() => _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState extends BaseToolScreenState<PercentageCalculatorScreen> {
  int _tab = 0;

  // Tab 1: X% of Y
  final _t1x = TextEditingController();
  final _t1y = TextEditingController();
  String _t1result = '';

  // Tab 2: X is what % of Y
  final _t2x = TextEditingController();
  final _t2y = TextEditingController();
  String _t2result = '';

  // Tab 3: % change
  final _t3from = TextEditingController();
  final _t3to   = TextEditingController();
  String _t3result = '';
  String _t3type   = '';

  // Tab 4: Add/Remove %
  final _t4val  = TextEditingController();
  final _t4pct  = TextEditingController();
  String _t4add = '';
  String _t4sub = '';

  void _calc1() {
    final x = double.tryParse(_t1x.text);
    final y = double.tryParse(_t1y.text);
    if (x == null || y == null) { setState(() => _t1result = ''); return; }
    setState(() => _t1result = _fmt(x / 100 * y));
  }

  void _calc2() {
    final x = double.tryParse(_t2x.text);
    final y = double.tryParse(_t2y.text);
    if (x == null || y == null || y == 0) { setState(() => _t2result = ''); return; }
    setState(() => _t2result = '${_fmt(x / y * 100)}%');
  }

  void _calc3() {
    final from = double.tryParse(_t3from.text);
    final to   = double.tryParse(_t3to.text);
    if (from == null || to == null || from == 0) { setState(() { _t3result = ''; _t3type = ''; }); return; }
    final change = (to - from) / from * 100;
    setState(() {
      _t3result = '${_fmt(change.abs())}%';
      _t3type   = change >= 0 ? '📈 Increase' : '📉 Decrease';
    });
  }

  void _calc4() {
    final val = double.tryParse(_t4val.text);
    final pct = double.tryParse(_t4pct.text);
    if (val == null || pct == null) { setState(() { _t4add = ''; _t4sub = ''; }); return; }
    setState(() {
      _t4add = _fmt(val + val * pct / 100);
      _t4sub = _fmt(val - val * pct / 100);
    });
  }

  String _fmt(double v) => v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(2);

  final _tabs = ['X% of Y', 'What %', '% Change', 'Add/Sub'];


  @override
  void dispose() {
    _t1x.dispose();
    _t1y.dispose();
    _t2x.dispose();
    _t2y.dispose();
    _t3from.dispose();
    _t3to.dispose();
    _t4val.dispose();
    _t4pct.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [
      // Tab bar
      Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor)),
          child: Row(children: List.generate(_tabs.length, (i) {
            final sel = _tab == i;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(gradient: sel ? AppTheme.brandGradient : null,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(_tabs[i], textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                        color: sel ? Colors.white : AppTheme.textSecondary,
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ));
          })),
        ),
      ),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: [_tab1, _tab2, _tab3, _tab4][_tab](),
      )),
    ]);
  }

  Widget _tab1() => Column(children: [
    _row(_t1x, 'Percentage (%)', _t1y, 'Value', onChanged: (_) => _calc1()),
    if (_t1result.isNotEmpty) _resultCard('$_t1result', '${_t1x.text}% of ${_t1y.text}'),
  ]);

  Widget _tab2() => Column(children: [
    _singleField(_t2x, 'Value (X)', onChanged: (_) => _calc2()),
    const SizedBox(height: 12),
    _singleField(_t2y, 'Total (Y)', onChanged: (_) => _calc2()),
    if (_t2result.isNotEmpty) _resultCard(_t2result, '${_t2x.text} is _t2result of ${_t2y.text}'),
  ]);

  Widget _tab3() => Column(children: [
    _row(_t3from, 'From Value', _t3to, 'To Value', onChanged: (_) => _calc3()),
    if (_t3result.isNotEmpty) ...[
      _resultCard(_t3result, _t3type),
      const SizedBox(height: 12),
      _resultCard('${_fmt((double.parse(_t3to.text) - double.parse(_t3from.text)).abs())}', 'Absolute Difference'),
    ],
  ]);

  Widget _tab4() => Column(children: [
    _row(_t4val, 'Original Value', _t4pct, 'Percentage (%)', onChanged: (_) => _calc4()),
    if (_t4add.isNotEmpty) ...[
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _miniResultCard('After Add\n(+${_t4pct.text}%)', _t4add, Colors.greenAccent)),
        const SizedBox(width: 12),
        Expanded(child: _miniResultCard('After Remove\n(-${_t4pct.text}%)', _t4sub, AppTheme.red)),
      ]),
    ],
  ]);

  Widget _row(TextEditingController c1, String l1, TextEditingController c2, String l2,
      {required ValueChanged<String> onChanged}) => Row(children: [
    Expanded(child: _singleField(c1, l1, onChanged: onChanged)),
    const SizedBox(width: 12),
    Expanded(child: _singleField(c2, l2, onChanged: onChanged)),
  ]);

  Widget _singleField(TextEditingController c, String label, {required ValueChanged<String> onChanged}) =>
      TextField(controller: c, onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
          decoration: InputDecoration(labelText: label,
              prefixIcon: const Icon(Icons.calculate_outlined)));

  Widget _resultCard(String value, String subtitle) => Container(
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [AppTheme.purple.withOpacity(0.2), AppTheme.pink.withOpacity(0.1)]),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
    ),
    child: Column(children: [
      ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
        child: Text(value, style: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 6),
      Text(subtitle, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () { Clipboard.setData(ClipboardData(text: value)); showSnack('Copied!'); },
        icon: const Icon(Icons.copy_outlined, size: 16),
        label: Text('Copy', style: GoogleFonts.rajdhani()),
        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple,
            side: BorderSide(color: AppTheme.purple.withOpacity(0.4))),
      ),
    ]),
  );

  Widget _miniResultCard(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4))),
    child: Column(children: [
      Text(label, textAlign: TextAlign.center,
          style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
      const SizedBox(height: 8),
      Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () { Clipboard.setData(ClipboardData(text: value)); showSnack('Copied!'); },
        child: Icon(Icons.copy_outlined, color: color, size: 18),
      ),
    ]),
  );
}
