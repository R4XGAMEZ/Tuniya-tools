import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class BaseConverterScreen extends BaseToolScreen {
  const BaseConverterScreen({super.key}) : super(toolId: 'base_converter');
  @override
  State<BaseConverterScreen> createState() => _BaseConverterScreenState();
}

class _BaseConverterScreenState extends BaseToolScreenState<BaseConverterScreen> {
  final _inputCtrl = TextEditingController();
  int _fromBase    = 10;
  Map<String, String> _results = {};
  bool _showBitView = false;

  final _bases = [
    _Base(2,  'BIN', 'Binary',      'Base 2'),
    _Base(8,  'OCT', 'Octal',       'Base 8'),
    _Base(10, 'DEC', 'Decimal',     'Base 10'),
    _Base(16, 'HEX', 'Hexadecimal', 'Base 16'),
    _Base(32, 'B32', 'Base 32',     'Base 32'),
    _Base(36, 'B36', 'Base 36',     'Base 36'),
    _Base(64, 'B64', 'Base 64',     'Base 64'),
  ];

  static const _chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';

  void _convert() {
    final input = _inputCtrl.text.trim().toUpperCase();
    if (input.isEmpty) { setState(() => _results = {}); return; }
    setError(null);
    try {
      // Parse input to decimal BigInt
      int decimal;
      if (_fromBase == 64) {
        // Special: base64 decode to int
        final bytes = base64Decode(input);
        decimal = bytes.fold(0, (acc, b) => acc * 256 + b);
      } else {
        decimal = int.parse(input, radix: _fromBase);
      }

      final res = <String, String>{};
      for (final b in _bases) {
        if (b.radix == 64) {
          // Base64 of decimal bytes
          final bytes = <int>[];
          int n = decimal;
          while (n > 0) { bytes.insert(0, n & 0xFF); n >>= 8; }
          if (bytes.isEmpty) bytes.add(0);
          res[b.name] = base64Encode(bytes);
        } else {
          res[b.name] = decimal == 0 ? '0' : _toBase(decimal, b.radix);
        }
      }
      setState(() => _results = res);
    } catch (e) {
      setError('Invalid input for base $_fromBase: $e');
      setState(() => _results = {});
    }
  }

  String _toBase(int n, int base) {
    if (n == 0) return '0';
    final buf = StringBuffer();
    while (n > 0) {
      buf.write(_chars[n % base]);
      n ~/= base;
    }
    return buf.toString().split('').reversed.join('');
  }

  String base64Encode(List<int> bytes) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final buf = StringBuffer();
    for (int i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i+1 < bytes.length ? bytes[i+1] : 0;
      final b2 = i+2 < bytes.length ? bytes[i+2] : 0;
      buf.write(chars[(b0 >> 2) & 0x3F]);
      buf.write(chars[((b0 << 4) | (b1 >> 4)) & 0x3F]);
      buf.write(i+1 < bytes.length ? chars[((b1 << 2) | (b2 >> 6)) & 0x3F] : '=');
      buf.write(i+2 < bytes.length ? chars[b2 & 0x3F] : '=');
    }
    return buf.toString();
  }

  List<int> base64Decode(String s) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    s = s.replaceAll('=', '');
    final bytes = <int>[];
    for (int i = 0; i < s.length; i += 4) {
      final n = (chars.indexOf(s[i]) << 18)
          | (i+1 < s.length ? chars.indexOf(s[i+1]) << 12 : 0)
          | (i+2 < s.length ? chars.indexOf(s[i+2]) << 6  : 0)
          | (i+3 < s.length ? chars.indexOf(s[i+3])       : 0);
      bytes.add((n >> 16) & 0xFF);
      if (i+2 < s.length) bytes.add((n >> 8) & 0xFF);
      if (i+3 < s.length) bytes.add(n & 0xFF);
    }
    return bytes;
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
        // From base selector
        Text('Input Base', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
            fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8,
          children: _bases.map((b) {
            final sel = _fromBase == b.radix;
            return GestureDetector(
              onTap: () { setState(() => _fromBase = b.radix); _convert(); },
              child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: sel ? AppTheme.brandGradient : null,
                  color: sel ? null : AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(b.short, style: GoogleFonts.orbitron(
                      color: sel ? Colors.white : AppTheme.purple,
                      fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(b.desc, style: GoogleFonts.rajdhani(
                      color: sel ? Colors.white70 : AppTheme.textSecondary, fontSize: 10)),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Input
        TextField(
          controller: _inputCtrl,
          onChanged: (_) => _convert(),
          style: GoogleFonts.robotoMono(color: AppTheme.textPrimary, fontSize: 15, letterSpacing: 1.5),
          decoration: InputDecoration(
            labelText: 'Input (Base $_fromBase)',
            hintText: _fromBase == 2 ? '1010' : _fromBase == 16 ? 'FF' : '255',
            suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() { _inputCtrl.clear(); _results = {}; })),
          ),
        ),
        const SizedBox(height: 20),

        if (_results.isNotEmpty) ...[
          Text('Conversions', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
              fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ..._bases.map((b) {
            final val = _results[b.name] ?? '';
            final isFrom = b.radix == _fromBase;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isFrom ? AppTheme.purple.withValues(alpha: 0.08) : AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isFrom ? AppTheme.purple.withValues(alpha: 0.5) : AppTheme.borderColor,
                    width: isFrom ? 1.5 : 1),
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(b.short, style: GoogleFonts.orbitron(color: AppTheme.purple,
                        fontSize: 12, fontWeight: FontWeight.bold)),
                    if (isFrom) ...[
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('INPUT', style: GoogleFonts.orbitron(
                            color: AppTheme.purple, fontSize: 8))),
                    ],
                  ]),
                  Text(b.name, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
                ]),
                const SizedBox(width: 14),
                Expanded(child: Text(val,
                    style: GoogleFonts.robotoMono(color: AppTheme.textPrimary,
                        fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  color: AppTheme.textSecondary, padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () { Clipboard.setData(ClipboardData(text: val)); showSnack('${b.short} copied!'); },
                ),
              ]),
            );
          }),

          // Bit view for decimal
          if (_results.containsKey('DEC')) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _showBitView = !_showBitView),
              child: Row(children: [
                Icon(_showBitView ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.purple, size: 20),
                Text(' Bit View (32-bit)', style: GoogleFonts.rajdhani(
                    color: AppTheme.purple, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
            if (_showBitView) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor)),
                child: Wrap(spacing: 4, runSpacing: 4,
                  children: List.generate(32, (i) {
                    final bit = 31 - i;
                    final dec = int.tryParse(_results['DEC'] ?? '0') ?? 0;
                    final isSet = (dec >> bit) & 1 == 1;
                    return Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: isSet ? AppTheme.purple : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Center(child: Text(isSet ? '1' : '0',
                          style: GoogleFonts.orbitron(
                              color: isSet ? Colors.white : AppTheme.textSecondary,
                              fontSize: 9, fontWeight: FontWeight.bold))),
                    );
                  }),
                ),
              ),
            ],
          ],
        ],
      ]),
    );
  }
}

class _Base { final int radix; final String short, name, desc;
  const _Base(this.radix, this.short, this.name, this.desc); }
