import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class CsvJsonConverterScreen extends BaseToolScreen {
  const CsvJsonConverterScreen({super.key}) : super(toolId: 'csv_json_converter');
  @override
  State<CsvJsonConverterScreen> createState() => _CsvJsonConverterScreenState();
}

class _CsvJsonConverterScreenState extends BaseToolScreenState<CsvJsonConverterScreen> {
  final _inputCtrl  = TextEditingController();
  final _outputCtrl = TextEditingController();
  bool _csvToJson   = true;
  String _separator = ',';
  bool _prettify    = true;

  void _convert() {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) { setError('Kuch daalo!'); return; }
    setError(null);
    try {
      if (_csvToJson) {
        setState(() => _outputCtrl.text = _csvToJsonStr(input));
      } else {
        setState(() => _outputCtrl.text = _jsonToCsvStr(input));
      }
      showSnack('Convert ho gaya ✅');
    } catch (e) {
      setError('Error: $e');
    }
  }

  String _csvToJsonStr(String csv) {
    final lines  = csv.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) throw 'Empty CSV';
    final headers = _splitLine(lines[0]);
    final rows    = lines.skip(1).map((line) {
      final vals = _splitLine(line);
      final map  = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        final val = i < vals.length ? vals[i].trim() : '';
        final num = double.tryParse(val);
        map[headers[i].trim()] = num != null ? (num == num.truncateToDouble() ? num.toInt() : num) : val;
      }
      return map;
    }).toList();
    return _prettify ? const JsonEncoder.withIndent('  ').convert(rows) : jsonEncode(rows);
  }

  String _jsonToCsvStr(String jsonStr) {
    final data = jsonDecode(jsonStr);
    if (data is! List || data.isEmpty) throw 'JSON must be a list of objects';
    final headers = (data[0] as Map).keys.toList();
    final lines   = <String>[headers.join(_separator)];
    for (final row in data) {
      if (row is Map) {
        lines.add(headers.map((h) {
          final v = row[h]?.toString() ?? '';
          return v.contains(_separator) || v.contains('"') ? '"${v.replaceAll('"','""')}"' : v;
        }).join(_separator));
      }
    }
    return lines.join('\n');
  }

  List<String> _splitLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    final buf = StringBuffer();
    for (int i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') { inQuotes = !inQuotes; continue; }
      if (!inQuotes && c == _separator) { result.add(buf.toString()); buf.clear(); continue; }
      buf.write(c);
    }
    result.add(buf.toString());
    return result;
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
          decoration: BoxDecoration(color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor)),
          child: Row(children: [
            _modeBtn('CSV → JSON', true),
            _modeBtn('JSON → CSV', false),
          ]),
        ),
        const SizedBox(height: 14),

        // Options
        Row(children: [
          Expanded(child: _optCard('Separator',
            DropdownButton<String>(
              value: _separator, dropdownColor: AppTheme.cardBg2,
              underline: const SizedBox(), isExpanded: true,
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
              items: [
                DropdownMenuItem(value: ',',  child: Text('Comma (,)')),
                DropdownMenuItem(value: ';',  child: Text('Semicolon (;)')),
                DropdownMenuItem(value: '\t', child: Text('Tab')),
                DropdownMenuItem(value: '|',  child: Text('Pipe (|)')),
              ],
              onChanged: (v) => setState(() => _separator = v!),
            ),
          )),
          const SizedBox(width: 12),
          if (_csvToJson)
            Expanded(child: _optCard('JSON Format',
              SwitchListTile(
                value: _prettify, onChanged: (v) => setState(() => _prettify = v),
                activeColor: AppTheme.purple, contentPadding: EdgeInsets.zero,
                title: Text(_prettify ? 'Pretty' : 'Minified',
                    style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
              ),
            )),
        ]),
        const SizedBox(height: 14),

        // Input
        TextField(
          controller: _inputCtrl, maxLines: 8,
          style: GoogleFonts.robotoMono(color: AppTheme.textPrimary, fontSize: 11),
          decoration: InputDecoration(
            labelText: _csvToJson ? 'CSV Input' : 'JSON Input',
            alignLabelWithHint: true,
            hintText: _csvToJson ? 'name,age,city\nAli,25,Delhi' : '[{"name":"Ali","age":25}]',
            suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() { _inputCtrl.clear(); _outputCtrl.clear(); })),
          ),
        ),
        const SizedBox(height: 12),

        GradientButton(label: 'Convert Karo', icon: Icons.swap_horiz_outlined, onPressed: _convert),

        if (_outputCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_csvToJson ? 'JSON Output' : 'CSV Output',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Row(children: [
              IconButton(icon: const Icon(Icons.copy_outlined, size: 18), color: AppTheme.purple,
                  onPressed: () { Clipboard.setData(ClipboardData(text: _outputCtrl.text)); showSnack('Copied!'); }),
              IconButton(icon: const Icon(Icons.south_outlined, size: 18), color: AppTheme.textSecondary,
                  tooltip: 'Use as input',
                  onPressed: () => setState(() { _inputCtrl.text = _outputCtrl.text;
                    _outputCtrl.clear(); _csvToJson = !_csvToJson; })),
            ]),
          ]),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.purple.withOpacity(0.4))),
            child: SelectableText(_outputCtrl.text,
                style: GoogleFonts.robotoMono(color: AppTheme.textPrimary, fontSize: 11, height: 1.5)),
          ),
        ],
      ]),
    );
  }

  Widget _modeBtn(String label, bool isCsvToJson) {
    final sel = _csvToJson == isCsvToJson;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _csvToJson = isCsvToJson),
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(gradient: sel ? AppTheme.brandGradient : null,
            borderRadius: BorderRadius.circular(10)),
        child: Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(color: sel ? Colors.white : AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    ));
  }

  Widget _optCard(String label, Widget child) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
    decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
      child,
    ]),
  );
}
