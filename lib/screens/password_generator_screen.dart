import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class PasswordGeneratorScreen extends BaseToolScreen {
  const PasswordGeneratorScreen({super.key}) : super(toolId: 'password_generator');
  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends BaseToolScreenState<PasswordGeneratorScreen> {
  int    _length     = 16;
  bool   _upper      = true;
  bool   _lower      = true;
  bool   _digits     = true;
  bool   _symbols    = true;
  bool   _noAmbig    = false; // exclude 0,O,l,I,1
  String _password   = '';
  int    _batchCount = 1;
  List<String> _batch = [];

  static const _upperChars  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lowerChars  = 'abcdefghijklmnopqrstuvwxyz';
  static const _digitChars  = '0123456789';
  static const _symbolChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const _ambiguous   = 'O0Il1';

  String _buildCharset() {
    String cs = '';
    if (_upper)  cs += _upperChars;
    if (_lower)  cs += _lowerChars;
    if (_digits) cs += _digitChars;
    if (_symbols)cs += _symbolChars;
    if (_noAmbig) cs = cs.split('').where((c) => !_ambiguous.contains(c)).join('');
    return cs;
  }

  String _generate() {
    final cs = _buildCharset();
    if (cs.isEmpty) return '';
    final rng = Random.secure();
    return List.generate(_length, (_) => cs[rng.nextInt(cs.length)]).join('');
  }

  void _generateOne() {
    if (!_upper && !_lower && !_digits && !_symbols) {
      setError('Kam se kam ek character type select karo!'); return;
    }
    setError(null);
    setState(() { _password = _generate(); _batch = []; });
  }

  void _generateBatch() {
    if (!_upper && !_lower && !_digits && !_symbols) {
      setError('Kam se kam ek type select karo!'); return;
    }
    setError(null);
    setState(() => _batch = List.generate(_batchCount, (_) => _generate()));
  }

  int _strength() {
    if (_password.isEmpty) return 0;
    int score = 0;
    if (_password.length >= 8)  score++;
    if (_password.length >= 12) score++;
    if (_password.length >= 16) score++;
    if (RegExp(r'[A-Z]').hasMatch(_password)) score++;
    if (RegExp(r'[a-z]').hasMatch(_password)) score++;
    if (RegExp(r'[0-9]').hasMatch(_password)) score++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(_password)) score++;
    return score.clamp(0, 5);
  }

  Color _strengthColor(int s) {
    if (s <= 1) return Colors.red;
    if (s <= 2) return Colors.orange;
    if (s <= 3) return Colors.yellow;
    if (s <= 4) return Colors.lightGreen;
    return Colors.green;
  }

  String _strengthLabel(int s) {
    const labels = ['', 'Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'];
    return s < labels.length ? labels[s] : 'Very Strong';
  }

  @override
  Widget buildBody(BuildContext context) {
    final strength = _strength();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // Length slider
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Password Length', style: GoogleFonts.rajdhani(
                  color: AppTheme.textSecondary, fontSize: 13)),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
                child: Text('$_length', style: GoogleFonts.orbitron(
                    fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ]),
            Slider(value: _length.toDouble(), min: 4, max: 64, divisions: 60,
                activeColor: AppTheme.purple,
                onChanged: (v) { setState(() => _length = v.round()); if (_password.isNotEmpty) _generateOne(); }),
          ]),
        ),
        const SizedBox(height: 14),

        // Character types
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor)),
          child: Column(children: [
            _toggleRow('Uppercase (A–Z)',     _upper,   (v) { setState(() => _upper   = v); }),
            _toggleRow('Lowercase (a–z)',     _lower,   (v) { setState(() => _lower   = v); }),
            _toggleRow('Digits (0–9)',        _digits,  (v) { setState(() => _digits  = v); }),
            _toggleRow('Symbols (!@#\$...)',  _symbols, (v) { setState(() => _symbols = v); }),
            const Divider(height: 16),
            _toggleRow('Exclude Ambiguous (0,O,l,I)', _noAmbig, (v) { setState(() => _noAmbig = v); }),
          ]),
        ),
        const SizedBox(height: 16),

        GradientButton(label: 'Generate Password',
            icon: Icons.key_outlined, onPressed: _generateOne),

        if (_password.isNotEmpty) ...[
          const SizedBox(height: 16),
          // Password display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.purple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
            ),
            child: Column(children: [
              SelectableText(_password, textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono(color: AppTheme.textPrimary,
                      fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 14),
              // Strength bar
              Row(children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: strength / 5,
                    minHeight: 6,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: AlwaysStoppedAnimation(_strengthColor(strength)),
                  ),
                )),
                const SizedBox(width: 10),
                Text(_strengthLabel(strength),
                    style: GoogleFonts.rajdhani(color: _strengthColor(strength),
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () { Clipboard.setData(ClipboardData(text: _password)); showSnack('Copied!'); },
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: Text('Copy', style: GoogleFonts.rajdhani()),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple,
                      side: BorderSide(color: AppTheme.purple.withOpacity(0.5))),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  onPressed: _generateOne,
                  icon: const Icon(Icons.refresh_outlined, size: 16),
                  label: Text('Refresh', style: GoogleFonts.rajdhani()),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.borderColor)),
                )),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Batch generate
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Batch Generate', style: GoogleFonts.rajdhani(
                    color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                Row(children: [
                  IconButton(icon: const Icon(Icons.remove, size: 18), color: AppTheme.textSecondary,
                      onPressed: () => setState(() => _batchCount = (_batchCount - 1).clamp(1, 20))),
                  Text('$_batchCount', style: GoogleFonts.orbitron(
                      color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add, size: 18), color: AppTheme.purple,
                      onPressed: () => setState(() => _batchCount = (_batchCount + 1).clamp(1, 20))),
                ]),
              ]),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _generateBatch,
                  icon: const Icon(Icons.list_outlined, size: 18),
                  label: Text('$_batchCount Passwords Banao', style: GoogleFonts.rajdhani()),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple,
                      side: BorderSide(color: AppTheme.purple.withOpacity(0.5)),
                      padding: const EdgeInsets.all(12)),
                ),
              ),
            ]),
          ),

          if (_batch.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${_batch.length} Passwords', style: GoogleFonts.rajdhani(
                      color: AppTheme.textSecondary, fontSize: 12)),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _batch.join('\n')));
                      showSnack('Sab copy ho gaye!');
                    },
                    icon: const Icon(Icons.copy_all_outlined, size: 16),
                    label: Text('Copy All', style: GoogleFonts.rajdhani()),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.purple),
                  ),
                ]),
                ..._batch.map((p) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    Expanded(child: Text(p,
                        style: GoogleFonts.robotoMono(
                            color: AppTheme.textPrimary, fontSize: 12))),
                    IconButton(icon: const Icon(Icons.copy_outlined, size: 16),
                        color: AppTheme.textSecondary, padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () { Clipboard.setData(ClipboardData(text: p)); showSnack('Copied!'); }),
                  ]),
                )),
              ]),
            ),
          ],
        ],
      ]),
    );
  }

  Widget _toggleRow(String label, bool val, ValueChanged<bool> onChanged) => SwitchListTile(
    value: val, onChanged: onChanged, activeColor: AppTheme.purple,
    contentPadding: EdgeInsets.zero, dense: true,
    title: Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
  );
}
