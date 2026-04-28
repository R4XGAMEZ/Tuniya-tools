import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class HashGeneratorScreen extends BaseToolScreen {
  const HashGeneratorScreen({super.key}) : super(toolId: 'hash_generator');
  @override
  State<HashGeneratorScreen> createState() => _HashGeneratorScreenState();
}

class _HashGeneratorScreenState extends BaseToolScreenState<HashGeneratorScreen> {
  final _inputCtrl = TextEditingController();
  bool _inputIsFile = false;
  bool _uppercase   = false;
  Map<String, String> _hashes = {};

  final _algos = ['MD5', 'SHA-1', 'SHA-224', 'SHA-256', 'SHA-384', 'SHA-512'];

  void _generate() {
    final text = _inputCtrl.text;
    if (text.trim().isEmpty) { setError('Kuch text daalo!'); return; }
    setError(null);
    final bytes = utf8.encode(text);
    final results = <String, String>{};

    results['MD5']    = md5.convert(bytes).toString();
    results['SHA-1']  = sha1.convert(bytes).toString();
    results['SHA-224']= sha224.convert(bytes).toString();
    results['SHA-256']= sha256.convert(bytes).toString();
    results['SHA-384']= sha384.convert(bytes).toString();
    results['SHA-512']= sha512.convert(bytes).toString();

    if (_uppercase) {
      results.updateAll((k, v) => v.toUpperCase());
    }
    setState(() => _hashes = results);
    showSnack('Hash generate ho gaya ✅');
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
          maxLines: 5,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Input Text',
            alignLabelWithHint: true,
            hintText: 'Hash karna hai kya...',
            suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() { _inputCtrl.clear(); _hashes = {}; })),
          ),
        ),
        const SizedBox(height: 12),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Output Format', style: GoogleFonts.rajdhani(
              color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          Row(children: [
            Text('lowercase', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
            Switch(value: _uppercase, activeColor: AppTheme.purple,
                onChanged: (v) { setState(() => _uppercase = v); if (_hashes.isNotEmpty) _generate(); }),
            Text('UPPERCASE', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 14),

        GradientButton(label: 'Hash Generate Karo',
            icon: Icons.fingerprint_outlined, onPressed: _generate),

        if (_hashes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Results', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
              fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ..._hashes.entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(e.key, style: GoogleFonts.orbitron(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  color: AppTheme.purple, padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: e.value));
                    showSnack('${e.key} copied!');
                  },
                ),
              ]),
              const SizedBox(height: 8),
              SelectableText(e.value,
                  style: GoogleFonts.robotoMono(
                      color: AppTheme.textPrimary, fontSize: 11, height: 1.4)),
            ]),
          )),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              final all = _hashes.entries.map((e) => '${e.key}:\n${e.value}').join('\n\n');
              Clipboard.setData(ClipboardData(text: all));
              showSnack('Sab copy ho gaya!');
            },
            icon: const Icon(Icons.copy_all_outlined, size: 18),
            label: Text('Copy All Hashes', style: GoogleFonts.rajdhani()),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple,
                side: BorderSide(color: AppTheme.purple.withOpacity(0.5)),
                padding: const EdgeInsets.all(14)),
          ),
        ],
      ]),
    );
  }
}
