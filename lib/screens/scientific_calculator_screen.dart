import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class ScientificCalculatorScreen extends BaseToolScreen {
  const ScientificCalculatorScreen({super.key}) : super(toolId: 'scientific_calculator');
  @override
  State<ScientificCalculatorScreen> createState() => _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState extends BaseToolScreenState<ScientificCalculatorScreen> {
  String _display   = '0';
  String _expr      = '';
  String _result    = '';
  bool   _isRad     = true;
  bool   _shift     = false;
  List<String> _history = [];

  void _press(String key) {
    setState(() {
      switch (key) {
        case 'C':  _display = '0'; _expr = ''; _result = ''; break;
        case '⌫':
          _display = _display.length > 1 ? _display.substring(0, _display.length - 1) : '0';
          _expr = _expr.isNotEmpty ? _expr.substring(0, _expr.length - 1) : '';
          break;
        case '=':  _evaluate(); break;
        case 'RAD': _isRad = !_isRad; break;
        case 'SHIFT': _shift = !_shift; break;
        default:   _appendKey(key);
      }
    });
  }

  void _appendKey(String key) {
    final map = {
      'sin': _isRad ? 'sin(' : 'sind(',
      'cos': _isRad ? 'cos(' : 'cosd(',
      'tan': _isRad ? 'tan(' : 'tand(',
      'sin⁻¹': _isRad ? 'asin(' : 'asind(',
      'cos⁻¹': _isRad ? 'acos(' : 'acosd(',
      'tan⁻¹': _isRad ? 'atan(' : 'atand(',
      'log': 'log(', 'ln': 'ln(', '√': 'sqrt(',
      'x²': '^2', 'x³': '^3', 'xʸ': '^',
      '10ˣ': '10^', 'eˣ': 'e^',
      'π': 'π', 'e': 'e',
      '(': '(', ')': ')',
      '1/x': '1/',
      '|x|': 'abs(',
      'n!': '!',
    };
    final token = map[key] ?? key;
    if (_display == '0' && RegExp(r'[0-9]').hasMatch(token)) {
      _display = token; _expr = token;
    } else {
      _display = _expr + token;
      _expr    = _display;
    }
  }

  void _evaluate() {
    try {
      final result = _calc(_expr);
      final formatted = result == result.truncateToDouble()
          ? result.toInt().toString()
          : result.toStringAsPrecision(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      _history.insert(0, '$_expr = $formatted');
      if (_history.length > 20) _history.removeLast();
      _result  = formatted;
      _display = formatted;
      _expr    = formatted;
    } catch (e) {
      _display = 'Error';
      _expr    = '';
    }
  }

  double _calc(String expr) {
    expr = expr.trim()
        .replaceAll('π', math.pi.toString())
        .replaceAll('e^', 'EXP^')
        .replaceAll('e', math.e.toString())
        .replaceAll('EXP^', 'e^');
    return _parseExpr(expr);
  }

  double _parseExpr(String s) {
    s = s.trim();
    // Find last + or - not inside parentheses
    int depth = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (s[i] == ')') depth++;
      else if (s[i] == '(') depth--;
      else if (depth == 0 && (s[i] == '+' || (s[i] == '-' && i > 0))) {
        final left = _parseExpr(s.substring(0, i));
        final right = _parseTerm(s.substring(i + 1));
        return s[i] == '+' ? left + right : left - right;
      }
    }
    return _parseTerm(s);
  }

  double _parseTerm(String s) {
    s = s.trim();
    for (int i = s.length - 1; i >= 0; i--) {
      if (s[i] == ')') { }
      else if (s[i] == '*' || s[i] == '×') {
        return _parseTerm(s.substring(0, i)) * _parsePow(s.substring(i + 1));
      } else if (s[i] == '/' || s[i] == '÷') {
        return _parseTerm(s.substring(0, i)) / _parsePow(s.substring(i + 1));
      } else if (s[i] == '%') {
        return _parseTerm(s.substring(0, i)) / 100;
      }
    }
    return _parsePow(s);
  }

  double _parsePow(String s) {
    s = s.trim();
    final idx = s.lastIndexOf('^');
    if (idx >= 0) {
      return math.pow(_parseUnary(s.substring(0, idx)), _parseUnary(s.substring(idx + 1))).toDouble();
    }
    return _parseUnary(s);
  }

  double _parseUnary(String s) {
    s = s.trim();
    if (s.startsWith('-')) return -_parseAtom(s.substring(1));
    if (s.endsWith('!')) {
      final n = _parseAtom(s.substring(0, s.length - 1)).round();
      double f = 1; for (int i = 2; i <= n; i++) f *= i;
      return f;
    }
    for (final fn in ['sind','cosd','tand','asind','acosd','atand','sin','cos','tan','asin','acos','atan','sqrt','log','ln','abs','log10']) {
      if (s.startsWith('$fn(') && s.endsWith(')')) {
        final inner = _parseExpr(s.substring(fn.length + 1, s.length - 1));
        final deg = fn.endsWith('d');
        final rad = deg ? inner * math.pi / 180 : inner;
        switch (fn.replaceAll('d','')) {
          case 'sin':   return math.sin(rad);
          case 'cos':   return math.cos(rad);
          case 'tan':   return math.tan(rad);
          case 'asin':  return deg ? math.asin(inner) * 180 / math.pi : math.asin(inner);
          case 'acos':  return deg ? math.acos(inner) * 180 / math.pi : math.acos(inner);
          case 'atan':  return deg ? math.atan(inner) * 180 / math.pi : math.atan(inner);
          case 'sqrt':  return math.sqrt(inner);
          case 'log':
          case 'log10': return math.log(inner) / math.log(10);
          case 'ln':    return math.log(inner);
          case 'abs':   return inner.abs();
        }
      }
    }
    return _parseAtom(s);
  }

  double _parseAtom(String s) {
    s = s.trim();
    if (s.startsWith('(') && s.endsWith(')')) return _parseExpr(s.substring(1, s.length - 1));
    return double.parse(s);
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [
      // Display
      Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(color: AppTheme.cardBg2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (_expr.isNotEmpty && _display != _expr)
            Text(_expr, style: GoogleFonts.rajdhani(
                color: AppTheme.textSecondary, fontSize: 14), overflow: TextOverflow.ellipsis),
          Text(_display, style: GoogleFonts.orbitron(
              color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ]),
      ),

      // Mode buttons
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          _modeBtn(_isRad ? 'RAD' : 'DEG', 'RAD', _isRad ? AppTheme.purple : AppTheme.textSecondary),
          const SizedBox(width: 8),
          _modeBtn('SHIFT', 'SHIFT', _shift ? Colors.orangeAccent : AppTheme.textSecondary),
          const Spacer(),
          if (_history.isNotEmpty)
            TextButton.icon(
              onPressed: () => _showHistory(context),
              icon: const Icon(Icons.history, size: 16),
              label: Text('History', style: GoogleFonts.rajdhani()),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            ),
        ]),
      ),

      // Keypad
      Expanded(child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.count(
          crossAxisCount: 5,
          mainAxisSpacing: 6, crossAxisSpacing: 6,
          physics: const NeverScrollableScrollPhysics(),
          children: _buildKeys().map((k) => _keyButton(k)).toList(),
        ),
      )),
    ]);
  }

  List<_Key> _buildKeys() {
    if (_shift) {
      return [
        _Key('sin⁻¹', AppTheme.purple), _Key('cos⁻¹', AppTheme.purple),
        _Key('tan⁻¹', AppTheme.purple), _Key('10ˣ', AppTheme.purple),
        _Key('eˣ', AppTheme.purple),
        _Key('(', AppTheme.textSecondary), _Key(')', AppTheme.textSecondary),
        _Key('n!', AppTheme.textSecondary), _Key('1/x', AppTheme.textSecondary),
        _Key('|x|', AppTheme.textSecondary),
        _Key('7', AppTheme.textPrimary), _Key('8', AppTheme.textPrimary),
        _Key('9', AppTheme.textPrimary), _Key('÷', AppTheme.red),
        _Key('⌫', AppTheme.red),
        _Key('4', AppTheme.textPrimary), _Key('5', AppTheme.textPrimary),
        _Key('6', AppTheme.textPrimary), _Key('×', AppTheme.red),
        _Key('C', AppTheme.red),
        _Key('1', AppTheme.textPrimary), _Key('2', AppTheme.textPrimary),
        _Key('3', AppTheme.textPrimary), _Key('-', AppTheme.red),
        _Key('%', AppTheme.textSecondary),
        _Key('0', AppTheme.textPrimary), _Key('.', AppTheme.textPrimary),
        _Key('π', AppTheme.purple), _Key('+', AppTheme.red),
        _Key('=', null, isEqual: true),
      ];
    }
    return [
      _Key('sin', AppTheme.purple), _Key('cos', AppTheme.purple),
      _Key('tan', AppTheme.purple), _Key('log', AppTheme.purple),
      _Key('ln', AppTheme.purple),
      _Key('(', AppTheme.textSecondary), _Key(')', AppTheme.textSecondary),
      _Key('√', AppTheme.textSecondary), _Key('x²', AppTheme.textSecondary),
      _Key('xʸ', AppTheme.textSecondary),
      _Key('7', AppTheme.textPrimary), _Key('8', AppTheme.textPrimary),
      _Key('9', AppTheme.textPrimary), _Key('÷', AppTheme.red),
      _Key('⌫', AppTheme.red),
      _Key('4', AppTheme.textPrimary), _Key('5', AppTheme.textPrimary),
      _Key('6', AppTheme.textPrimary), _Key('×', AppTheme.red),
      _Key('C', AppTheme.red),
      _Key('1', AppTheme.textPrimary), _Key('2', AppTheme.textPrimary),
      _Key('3', AppTheme.textPrimary), _Key('-', AppTheme.red),
      _Key('%', AppTheme.textSecondary),
      _Key('0', AppTheme.textPrimary), _Key('.', AppTheme.textPrimary),
      _Key('e', AppTheme.purple), _Key('+', AppTheme.red),
      _Key('=', null, isEqual: true),
    ];
  }

  Widget _keyButton(_Key k) {
    return GestureDetector(
      onTap: () => _press(k.label == '×' ? '*' : k.label == '÷' ? '/' : k.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          gradient: k.isEqual ? AppTheme.brandGradient : null,
          color: k.isEqual ? null : AppTheme.cardBg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Center(child: Text(k.label,
            style: GoogleFonts.rajdhani(
              color: k.isEqual ? Colors.white : (k.color ?? AppTheme.textPrimary),
              fontSize: k.label.length > 3 ? 11 : 16,
              fontWeight: FontWeight.w600,
            ))),
      ),
    );
  }

  Widget _modeBtn(String label, String key, Color color) => GestureDetector(
    onTap: () => _press(key),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4))),
      child: Text(label, style: GoogleFonts.orbitron(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    ),
  );

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(children: [
        Padding(padding: const EdgeInsets.all(16),
          child: Text('History', style: GoogleFonts.rajdhani(
              color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600))),
        Expanded(child: ListView.builder(
          itemCount: _history.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(_history[i], style: GoogleFonts.robotoMono(
                color: AppTheme.textPrimary, fontSize: 13)),
            trailing: IconButton(
              icon: const Icon(Icons.north_west_outlined, size: 16),
              color: AppTheme.purple,
              onPressed: () {
                final parts = _history[i].split(' = ');
                setState(() { _expr = parts[0]; _display = parts[0]; });
                Navigator.pop(context);
              },
            ),
          ),
        )),
      ]),
    );
  }
}

class _Key { final String label; final Color? color; final bool isEqual;
  const _Key(this.label, this.color, {this.isEqual = false}); }
