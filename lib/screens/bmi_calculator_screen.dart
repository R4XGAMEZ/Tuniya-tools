import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class BmiCalculatorScreen extends BaseToolScreen {
  const BmiCalculatorScreen({super.key}) : super(toolId: 'bmi_calculator');
  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends BaseToolScreenState<BmiCalculatorScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  bool _isCm = true;
  bool _isKg = true;
  double? _bmi;
  String _category = '';
  Color _catColor = Colors.green;

  void _calculate() {
    final h = double.tryParse(_heightCtrl.text.trim());
    final w = double.tryParse(_weightCtrl.text.trim());
    if (h == null || w == null || h == 0) { setError('Sahi values dalo!'); return; }
    setError(null);
    double heightM = _isCm ? h / 100 : h * 0.0254;
    double weightKg = _isKg ? w : w * 0.453592;
    final bmi = weightKg / (heightM * heightM);
    String cat;
    Color col;
    if (bmi < 18.5) { cat = 'Underweight 😟'; col = Colors.blue; }
    else if (bmi < 25) { cat = 'Normal Weight ✅'; col = Colors.green; }
    else if (bmi < 30) { cat = 'Overweight ⚠️'; col = Colors.orange; }
    else { cat = 'Obese 🚨'; col = AppTheme.red; }
    setState(() { _bmi = bmi; _category = cat; _catColor = col; });
  }


  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Unit toggles
        Row(children: [
          Expanded(child: _UnitToggle('Height Unit', ['cm', 'inches'], _isCm ? 0 : 1,
              (i) => setState(() { _isCm = i == 0; _bmi = null; }))),
          const SizedBox(width: 12),
          Expanded(child: _UnitToggle('Weight Unit', ['kg', 'lbs'], _isKg ? 0 : 1,
              (i) => setState(() { _isKg = i == 0; _bmi = null; }))),
        ]),
        const SizedBox(height: 16),
        _inputField(_heightCtrl, 'Height (${_isCm ? "cm" : "inches"})', Icons.height),
        const SizedBox(height: 12),
        _inputField(_weightCtrl, 'Weight (${_isKg ? "kg" : "lbs"})', Icons.monitor_weight_outlined),
        const SizedBox(height: 16),
        GradientButton(label: 'BMI Calculate Karo', icon: Icons.calculate_outlined, onPressed: _calculate),

        if (_bmi != null) ...[ 
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _catColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _catColor.withOpacity(0.5)),
            ),
            child: Column(children: [
              Text('Your BMI', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              Text(_bmi!.toStringAsFixed(1),
                  style: GoogleFonts.orbitron(color: _catColor, fontSize: 52, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_category, style: GoogleFonts.rajdhani(color: _catColor, fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 16),
          _bmiScaleWidget(),
        ],
      ]),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.purple, size: 20),
      ),
    );
  }

  Widget _UnitToggle(String label, List<String> opts, int selected, Function(int) onSel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
        child: Row(children: List.generate(opts.length, (i) => Expanded(
          child: GestureDetector(
            onTap: () => onSel(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: selected == i ? AppTheme.brandGradient : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(opts[i], textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(color: selected == i ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w700)),
            ),
          ),
        ))),
      ),
    ]);
  }

  Widget _bmiScaleWidget() {
    final categories = [
      ('Underweight', 0.0, 18.5, Colors.blue),
      ('Normal', 18.5, 25.0, Colors.green),
      ('Overweight', 25.0, 30.0, Colors.orange),
      ('Obese', 30.0, 40.0, AppTheme.red),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('BMI Categories', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...categories.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: c.$4, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(c.$1, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
            const Spacer(),
            Text('${c.$2} - ${c.$3}', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        )),
      ]),
    );
  }
}
