import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class SqlFormatterScreen extends BaseToolScreen {
  const SqlFormatterScreen({super.key}) : super(toolId: 'sql_formatter');
  @override
  State<SqlFormatterScreen> createState() => _SqlFormatterScreenState();
}

class _SqlFormatterScreenState extends BaseToolScreenState<SqlFormatterScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  bool _uppercase = true;
  bool _indent = true;

  // Keywords that start a new line
  static const _newlineKeywords = [
    'SELECT', 'FROM', 'WHERE', 'INNER JOIN', 'LEFT JOIN', 'RIGHT JOIN',
    'FULL JOIN', 'CROSS JOIN', 'JOIN', 'ON', 'AND', 'OR', 'GROUP BY',
    'ORDER BY', 'HAVING', 'LIMIT', 'OFFSET', 'UNION ALL', 'UNION',
    'INSERT INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE FROM',
    'CREATE TABLE', 'ALTER TABLE', 'DROP TABLE',
  ];

  // Keywords to just uppercase (inline)
  static const _inlineKeywords = [
    'AS', 'IN', 'NOT', 'NULL', 'IS', 'LIKE', 'BETWEEN', 'EXISTS',
    'DISTINCT', 'ALL', 'ANY', 'CASE', 'WHEN', 'THEN', 'ELSE', 'END',
    'ASC', 'DESC', 'COUNT', 'SUM', 'AVG', 'MAX', 'MIN', 'COALESCE',
    'IFNULL', 'NULLIF', 'CAST', 'CONVERT', 'DATE', 'NOW', 'INT',
    'VARCHAR', 'TEXT', 'PRIMARY', 'KEY', 'FOREIGN', 'REFERENCES',
    'DEFAULT', 'NOT NULL', 'UNIQUE', 'INDEX',
  ];

  String _format(String sql) {
    // Collapse whitespace
    String s = sql.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Apply newline keywords (longest first to avoid partial matches)
    final sorted = [..._newlineKeywords]..sort((a, b) => b.length.compareTo(a.length));
    for (final kw in sorted) {
      s = s.replaceAllMapped(
        RegExp('\\b$kw\\b', caseSensitive: false),
        (m) => '\n${_uppercase ? kw : kw.toLowerCase()}',
      );
    }

    // Apply inline keywords
    for (final kw in _inlineKeywords) {
      s = s.replaceAllMapped(
        RegExp('\\b$kw\\b', caseSensitive: false),
        (m) => _uppercase ? kw : kw.toLowerCase(),
      );
    }

    // Add indent to certain lines
    final lines = s.split('\n').map((line) => line.trim()).where((l) => l.isNotEmpty).toList();
    if (_indent) {
      final indented = <String>[];
      for (int i = 0; i < lines.length; i++) {
        final l = lines[i];
        final upper = l.toUpperCase();
        if (i == 0) {
          indented.add(l);
        } else if (upper.startsWith('AND') || upper.startsWith('OR')) {
          indented.add('    $l');
        } else {
          indented.add(l);
        }
      }
      return indented.join('\n');
    }
    return lines.join('\n');
  }

  void _formatSql() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) { setError('SQL paste karo!'); return; }
    setError(null);
    setState(() => _output = _format(text));
  }

  void _minify() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) { setError('SQL paste karo!'); return; }
    setError(null);
    setState(() => _output = text.replaceAll(RegExp(r'\s+'), ' ').trim());
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
          maxLines: 6,
          style: GoogleFonts.sourceCodePro(color: AppTheme.textPrimary, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'SQL query yahan paste karo...\nSELECT * FROM users WHERE id=1',
            hintStyle: GoogleFonts.sourceCodePro(color: AppTheme.textSecondary, fontSize: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() { _inputCtrl.clear(); _output = ''; }),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Options row
        Row(children: [
          Checkbox(
            value: _uppercase,
            onChanged: (v) => setState(() => _uppercase = v ?? true),
            activeColor: AppTheme.purple,
          ),
          Text('UPPERCASE Keywords',
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
          const SizedBox(width: 16),
          Checkbox(
            value: _indent,
            onChanged: (v) => setState(() => _indent = v ?? true),
            activeColor: AppTheme.purple,
          ),
          Text('Indent AND/OR',
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
        ]),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(child: GradientButton(
            label: 'Format Karo',
            icon: Icons.auto_fix_high_outlined,
            onPressed: _formatSql,
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.compress_outlined, size: 16),
            label: Text('Minify', style: GoogleFonts.rajdhani(fontSize: 14)),
            onPressed: _minify,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.borderColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )),
        ]),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Formatted SQL',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Row(children: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppTheme.purple,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _output));
                  showSnack('SQL copy ho gaya!');
                },
              ),
              IconButton(
                icon: const Icon(Icons.south_outlined, size: 18),
                color: AppTheme.textSecondary,
                onPressed: () => setState(() { _inputCtrl.text = _output; _output = ''; }),
              ),
            ]),
          ]),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
            ),
            child: SelectableText(
              _output,
              style: GoogleFonts.sourceCodePro(
                  color: const Color(0xFF79C0FF), fontSize: 12, height: 1.7),
            ),
          ),
        ],
      ]),
    );
  }
}
