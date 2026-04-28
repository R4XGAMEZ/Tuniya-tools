import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class PasswordStrengthScreen extends BaseToolScreen {
  const PasswordStrengthScreen({super.key}) : super(toolId: 'password_strength');
  @override
  State<PasswordStrengthScreen> createState() => _PasswordStrengthScreenState();
}

class _PasswordStrengthScreenState extends BaseToolScreenState<PasswordStrengthScreen> {
  final _ctrl = TextEditingController();
  bool _visible = false;
  _PasswordAnalysis _analysis = _PasswordAnalysis.empty();

  void _analyze(String password) {
    setState(() => _analysis = _PasswordAnalysis.analyze(password));
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
        TextField(
          controller: _ctrl,
          obscureText: !_visible,
          onChanged: _analyze,
          style: GoogleFonts.robotoMono(color: AppTheme.textPrimary, fontSize: 15, letterSpacing: 2),
          decoration: InputDecoration(
            labelText: 'Password Check Karo',
            hintText: 'Apna password enter karo...',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _visible = !_visible),
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (_ctrl.text.isNotEmpty) ...[
          // Strength meter
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _analysis.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _analysis.color.withOpacity(0.4)),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Strength', style: GoogleFonts.rajdhani(
                    color: AppTheme.textSecondary, fontSize: 13)),
                Text(_analysis.label, style: GoogleFonts.orbitron(
                    color: _analysis.color, fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _analysis.score / 5,
                  minHeight: 10,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation(_analysis.color),
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _statItem('Length',    '${_ctrl.text.length}', Icons.straighten_outlined),
                _statItem('Entropy',   '${_analysis.entropy.round()} bits', Icons.shield_outlined),
                _statItem('Crack Time',_analysis.crackTime, Icons.timer_outlined),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Checklist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Checklist', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ..._analysis.checks.map((c) => _checkRow(c.label, c.passed)),
            ]),
          ),
          const SizedBox(height: 14),

          // Suggestions
          if (_analysis.suggestions.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text('Suggestions', style: GoogleFonts.rajdhani(
                      color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 10),
                ..._analysis.suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    const Icon(Icons.arrow_right_outlined, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(s, style: GoogleFonts.rajdhani(
                        color: AppTheme.textPrimary, fontSize: 13))),
                  ]),
                )),
              ]),
            ),
          ],
        ] else ...[
          Center(child: Column(children: [
            const SizedBox(height: 40),
            Icon(Icons.lock_open_outlined, color: AppTheme.textSecondary.withOpacity(0.3), size: 60),
            const SizedBox(height: 16),
            Text('Password enter karo\nstrength check karne ke liye',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)),
          ])),
        ],
      ]),
    );
  }

  Widget _statItem(String label, String value, IconData icon) => Column(children: [
    Icon(icon, color: AppTheme.textSecondary, size: 18),
    const SizedBox(height: 6),
    Text(value, style: GoogleFonts.orbitron(color: AppTheme.textPrimary,
        fontSize: 12, fontWeight: FontWeight.bold)),
    Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
  ]);

  Widget _checkRow(String label, bool passed) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(passed ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: passed ? Colors.greenAccent : AppTheme.red, size: 18),
      const SizedBox(width: 10),
      Text(label, style: GoogleFonts.rajdhani(
          color: passed ? AppTheme.textPrimary : AppTheme.textSecondary, fontSize: 13)),
    ]),
  );
}

class _Check { final String label; final bool passed; _Check(this.label, this.passed); }

class _PasswordAnalysis {
  final int score;
  final String label;
  final Color color;
  final double entropy;
  final String crackTime;
  final List<_Check> checks;
  final List<String> suggestions;

  _PasswordAnalysis({required this.score, required this.label, required this.color,
      required this.entropy, required this.crackTime, required this.checks, required this.suggestions});

  factory _PasswordAnalysis.empty() => _PasswordAnalysis(
    score: 0, label: '', color: Colors.grey, entropy: 0, crackTime: '',
    checks: [], suggestions: [],
  );

  factory _PasswordAnalysis.analyze(String p) {
    final hasUpper   = RegExp(r'[A-Z]').hasMatch(p);
    final hasLower   = RegExp(r'[a-z]').hasMatch(p);
    final hasDigit   = RegExp(r'[0-9]').hasMatch(p);
    final hasSymbol  = RegExp(r'[^a-zA-Z0-9]').hasMatch(p);
    final len        = p.length;

    int poolSize = 0;
    if (hasLower)  poolSize += 26;
    if (hasUpper)  poolSize += 26;
    if (hasDigit)  poolSize += 10;
    if (hasSymbol) poolSize += 32;
    if (poolSize == 0) poolSize = 26;

    final entropy = len * (poolSize > 0 ? (poolSize.toDouble()).log2() : 0);

    int score = 0;
    if (len >= 8)  score++;
    if (len >= 12) score++;
    if (len >= 16) score++;
    if (hasUpper && hasLower) score++;
    if (hasDigit)  score++;
    if (hasSymbol) score++;
    score = score.clamp(0, 5);

    final labels = ['Very Weak','Weak','Fair','Good','Strong','Very Strong'];
    final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green, Colors.teal];

    // Crack time estimate (10B guesses/sec)
    final combinations = poolSize > 0 ? pow(poolSize.toDouble(), len.toDouble()) : 1.0;
    final seconds = combinations / 1e10;
    String crackTime;
    if (seconds < 1)          crackTime = 'Instant';
    else if (seconds < 60)    crackTime = '${seconds.round()}s';
    else if (seconds < 3600)  crackTime = '${(seconds/60).round()}m';
    else if (seconds < 86400) crackTime = '${(seconds/3600).round()}h';
    else if (seconds < 3.15e7)crackTime = '${(seconds/86400).round()}d';
    else if (seconds < 3.15e9)crackTime = '${(seconds/3.15e7).round()}y';
    else                       crackTime = 'Centuries';

    final checks = [
      _Check('8+ characters',         len >= 8),
      _Check('12+ characters',         len >= 12),
      _Check('Uppercase letters (A-Z)', hasUpper),
      _Check('Lowercase letters (a-z)', hasLower),
      _Check('Numbers (0-9)',           hasDigit),
      _Check('Special symbols (!@#...)',hasSymbol),
    ];

    final suggestions = <String>[];
    if (len < 12)    suggestions.add('Length badhao — 12+ characters use karo');
    if (!hasUpper)   suggestions.add('Uppercase letters add karo (A-Z)');
    if (!hasLower)   suggestions.add('Lowercase letters add karo (a-z)');
    if (!hasDigit)   suggestions.add('Numbers add karo (0-9)');
    if (!hasSymbol)  suggestions.add('Special characters add karo (!@#\$)');
    if (RegExp(r'(.)\1{2,}').hasMatch(p)) suggestions.add('Repeating characters avoid karo');

    return _PasswordAnalysis(
      score: score, label: labels[score], color: colors[score],
      entropy: entropy.toDouble(), crackTime: crackTime, checks: checks, suggestions: suggestions,
    );
  }
}

extension on double {
  double log2() => this <= 0 ? 0 : (ln(this) / ln(2.0));
  double ln(double x) => x <= 0 ? 0 : x.isInfinite ? double.infinity : _ln(x);
  double _ln(double x) {
    if (x <= 0) return double.negativeInfinity;
    double result = 0, term = (x - 1) / (x + 1), termPow = term;
    for (int i = 1; i <= 100; i += 2) { result += termPow / i; termPow *= term * term; }
    return 2 * result;
  }
}

double pow(double base, double exp) {
  if (exp == 0) return 1;
  if (exp > 300) return double.infinity;
  return double.parse(base.toString()).pow(exp);
}
extension _Pow on double { double pow(double e) => _powImpl(this, e); }
double _powImpl(double b, double e) {
  if (e == 0) return 1; if (b == 0) return 0;
  double result = 1; int n = e.round().clamp(0, 300);
  for (int i = 0; i < n; i++) { result *= b; if (result.isInfinite) return double.infinity; }
  return result;
}
