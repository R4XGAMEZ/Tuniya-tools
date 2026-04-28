import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class Base64Screen extends BaseToolScreen {
  const Base64Screen({super.key}) : super(toolId: 'base64_encoder');
  @override
  State<Base64Screen> createState() => _Base64ScreenState();
}

class _Base64ScreenState extends BaseToolScreenState<Base64Screen> {
  final _inputCtrl  = TextEditingController();
  final _outputCtrl = TextEditingController();
  bool _encodeMode  = true; // true = encode, false = decode
  String _variant   = 'standard'; // standard | url | mime

  void _process() {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) { setError('Kuch text daalo!'); return; }
    setError(null);
    try {
      String result;
      if (_encodeMode) {
        final bytes = utf8.encode(input);
        switch (_variant) {
          case 'url':  result = base64Url.encode(bytes); break;
          case 'mime': result = _toMime(bytes);          break;
          default:     result = base64.encode(bytes);
        }
      } else {
        // Decode
        String clean = input.replaceAll(RegExp(r'\s+'), '');
        // Add padding if needed
        final pad = clean.length % 4;
        if (pad != 0) clean += '=' * (4 - pad);
        final bytes = (_variant == 'url')
            ? base64Url.decode(clean)
            : base64.decode(clean);
        result = utf8.decode(bytes);
      }
      setState(() => _outputCtrl.text = result);
      showSnack(_encodeMode ? 'Encode ho gaya ✅' : 'Decode ho gaya ✅');
    } catch (e) {
      setError('Error: Invalid ${_encodeMode ? "text" : "Base64"} — $e');
    }
  }

  String _toMime(List<int> bytes) {
    final b64 = base64.encode(bytes);
    final buf = StringBuffer();
    for (int i = 0; i < b64.length; i += 76) {
      buf.writeln(b64.substring(i, (i + 76).clamp(0, b64.length)));
    }
    return buf.toString().trim();
  }

  void _swap() {
    setState(() {
      final tmp = _inputCtrl.text;
      _inputCtrl.text = _outputCtrl.text;
      _outputCtrl.text = tmp;
      _encodeMode = !_encodeMode;
    });
  }


  @override
  void dispose() {
    _inputCtrl.dispose();
    _outputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // Mode toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(children: [
            _modeBtn('Encode', true),
            _modeBtn('Decode', false),
          ]),
        ),
        const SizedBox(height: 16),

        // Variant selector
        Text('Variant',
            style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          _varChip('standard', 'Standard'),
          _varChip('url',      'URL-Safe'),
          _varChip('mime',     'MIME (76-char lines)'),
        ]),
        const SizedBox(height: 16),

        // Input
        TextField(
          controller: _inputCtrl,
          maxLines: 6,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            labelText: _encodeMode ? 'Plain Text (Input)' : 'Base64 (Input)',
            alignLabelWithHint: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() {
                _inputCtrl.clear(); _outputCtrl.clear();
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Process + Swap buttons
        Row(children: [
          Expanded(child: GradientButton(
            label: _encodeMode ? 'Encode Karo' : 'Decode Karo',
            icon: _encodeMode ? Icons.lock_outline : Icons.lock_open_outlined,
            onPressed: _process,
          )),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: IconButton(
              icon: const Icon(Icons.swap_vert_outlined),
              color: AppTheme.purple,
              tooltip: 'Swap & flip mode',
              onPressed: _swap,
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Output
        TextField(
          controller: _outputCtrl,
          maxLines: 6,
          readOnly: true,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            labelText: _encodeMode ? 'Base64 (Output)' : 'Plain Text (Output)',
            alignLabelWithHint: true,
            suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppTheme.purple,
                onPressed: _outputCtrl.text.isEmpty ? null : () {
                  Clipboard.setData(ClipboardData(text: _outputCtrl.text));
                  showSnack('Copy ho gaya!');
                },
              ),
            ]),
          ),
        ),

        if (_outputCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('Input',  '${_inputCtrl.text.length} chars'),
                _miniStat('Output', '${_outputCtrl.text.length} chars'),
                _miniStat('Ratio',
                    _inputCtrl.text.isEmpty ? '-'
                        : '${(_outputCtrl.text.length / _inputCtrl.text.length).toStringAsFixed(2)}x'),
              ],
            ),
          ),
        ],
      ]),
    );
  }

  Widget _modeBtn(String label, bool isEncode) {
    final sel = _encodeMode == isEncode;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _encodeMode = isEncode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: sel ? AppTheme.brandGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
                color: sel ? Colors.white : AppTheme.textSecondary,
                fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    ));
  }

  Widget _varChip(String id, String label) {
    final sel = _variant == id;
    return GestureDetector(
      onTap: () => setState(() => _variant = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: sel ? AppTheme.brandGradient : null,
          color: sel ? null : AppTheme.cardBg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor),
        ),
        child: Text(label,
            style: GoogleFonts.rajdhani(
                color: sel ? Colors.white : AppTheme.textSecondary,
                fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _miniStat(String label, String value) => Column(children: [
    Text(value,
        style: GoogleFonts.orbitron(
            color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
    Text(label,
        style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
  ]);
}
