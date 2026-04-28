import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class AgeCalculatorScreen extends BaseToolScreen {
  const AgeCalculatorScreen({super.key}) : super(toolId: 'age_calculator');
  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends BaseToolScreenState<AgeCalculatorScreen> {
  DateTime? _dob;
  Map<String, dynamic>? _result;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF9C27B0))),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() { _dob = picked; _result = null; });
    }
  }

  void _calculate() {
    if (_dob == null) { setError('Pehle date of birth chuno!'); return; }
    setError(null);
    final now = DateTime.now();
    int years = now.year - _dob!.year;
    int months = now.month - _dob!.month;
    int days = now.day - _dob!.day;
    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) { years--; months += 12; }
    final totalDays = now.difference(_dob!).inDays;
    final nextBday = DateTime(now.year, _dob!.month, _dob!.day);
    final nextBirthdayFinal = nextBday.isBefore(now) || nextBday == now
        ? DateTime(now.year + 1, _dob!.month, _dob!.day) : nextBday;
    final daysUntilBday = nextBirthdayFinal.difference(now).inDays;
    setState(() => _result = {
      'years': years, 'months': months, 'days': days,
      'totalDays': totalDays, 'totalWeeks': (totalDays / 7).floor(),
      'totalHours': totalDays * 24, 'daysUntilBday': daysUntilBday,
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // DOB picker
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _dob != null ? AppTheme.purple.withValues(alpha: 0.5) : AppTheme.borderColor),
            ),
            child: Row(children: [
              Icon(Icons.cake_outlined, color: AppTheme.purple, size: 22),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Date of Birth', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                Text(_dob != null ? '${_dob!.day}/${_dob!.month}/${_dob!.year}' : 'Tap karke date chuno',
                    style: GoogleFonts.rajdhani(color: _dob != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
              const Spacer(),
              Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        GradientButton(label: 'Umar Calculate Karo', icon: Icons.calculate_outlined, onPressed: _calculate),

        if (_result != null) ...[ 
          const SizedBox(height: 24),
          // Main age display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.purple.withValues(alpha: 0.15), AppTheme.red.withValues(alpha: 0.1)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.purple.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Text('Tumhari Umar', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _AgeBlock('${_result!["years"]}', 'Saal'),
                _AgeBlock('${_result!["months"]}', 'Mahine'),
                _AgeBlock('${_result!["days"]}', 'Din'),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          // Stats grid
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.8,
            children: [
              _StatCard('${_result!["totalDays"]}', 'Kul Din', Icons.today_outlined),
              _StatCard('${_result!["totalWeeks"]}', 'Kul Hafte', Icons.view_week_outlined),
              _StatCard('${_result!["totalHours"]}+', 'Kul Ghante', Icons.access_time_outlined),
              _StatCard('${_result!["daysUntilBday"]}', 'Din Birthday Tak', Icons.celebration_outlined),
            ],
          ),
        ],
      ]),
    );
  }

  Widget _AgeBlock(String val, String label) => Column(children: [
    ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
      child: Text(val, style: GoogleFonts.orbitron(fontSize: 36, fontWeight: FontWeight.bold)),
    ),
    Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
  ]);

  Widget _StatCard(String val, String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
    child: Row(children: [
      Icon(icon, color: AppTheme.purple, size: 20),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(val, style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    ]),
  );
}
