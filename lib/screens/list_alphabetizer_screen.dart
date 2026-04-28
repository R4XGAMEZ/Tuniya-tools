import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class ListAlphabetizerScreen extends BaseToolScreen {
  const ListAlphabetizerScreen({super.key}) : super(toolId: 'list_alphabetizer');
  @override
  State<ListAlphabetizerScreen> createState() => _ListAlphabetizerScreenState();
}

class _ListAlphabetizerScreenState extends BaseToolScreenState<ListAlphabetizerScreen> {
  final _inputCtrl = TextEditingController();
  String _output   = '';
  String _sortMode = 'az';
  bool _removeDupes = false;
  bool _trimLines   = true;
  bool _ignoreCase  = true;
  String _separator = 'newline';

  String get _sepChar {
    switch (_separator) {
      case 'comma':     return ',';
      case 'semicolon': return ';';
      case 'pipe':      return '|';
      default:          return '\n';
    }
  }

  void _sort() {
    final text = _inputCtrl.text;
    if (text.trim().isEmpty) { setError('List daalo!'); return; }
    setError(null);

    List<String> items = text.split(_sepChar)
        .map((e) => _trimLines ? e.trim() : e).toList();
    items = items.where((e) => e.isNotEmpty).toList();

    if (_removeDupes) {
      final seen = <String>{};
      items = items.where((e) => seen.add(_ignoreCase ? e.toLowerCase() : e)).toList();
    }

    switch (_sortMode) {
      case 'az':
        items.sort((a, b) => _ignoreCase
            ? a.toLowerCase().compareTo(b.toLowerCase())
            : a.compareTo(b));
        break;
      case 'za':
        items.sort((a, b) => _ignoreCase
            ? b.toLowerCase().compareTo(a.toLowerCase())
            : b.compareTo(a));
        break;
      case 'shortest':
        items.sort((a, b) => a.length.compareTo(b.length));
        break;
      case 'longest':
        items.sort((a, b) => b.length.compareTo(a.length));
        break;
      case 'random':
        items.shuffle();
        break;
      case 'reverse':
        items = items.reversed.toList();
        break;
    }

    setState(() => _output = items.join(_sepChar == '\n' ? '\n' : '$_sepChar '));
    showSnack('${items.length} items sorted ✅');
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
          maxLines: 7,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Banana\nApple\nMango\nCherry',
            alignLabelWithHint: true,
            labelText: 'List Items',
            suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() { _inputCtrl.clear(); _output = ''; })),
          ),
        ),
        const SizedBox(height: 14),

        // Sort mode
        Text('Sort Mode', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
            fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _chip('az',       'A → Z',      Icons.sort_by_alpha_outlined),
          _chip('za',       'Z → A',      Icons.sort_outlined),
          _chip('shortest', 'Shortest',   Icons.vertical_align_bottom_outlined),
          _chip('longest',  'Longest',    Icons.vertical_align_top_outlined),
          _chip('random',   'Shuffle',    Icons.shuffle_outlined),
          _chip('reverse',  'Reverse',    Icons.swap_vert_outlined),
        ]),
        const SizedBox(height: 14),

        // Separator
        Text('Separator', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
            fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          _sepChip('newline',   'New Line'),
          _sepChip('comma',     'Comma'),
          _sepChip('semicolon', 'Semicolon'),
          _sepChip('pipe',      'Pipe |'),
        ]),
        const SizedBox(height: 14),

        // Options
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor)),
          child: Column(children: [
            _switchRow('Remove Duplicates', _removeDupes, (v) => setState(() => _removeDupes = v)),
            _switchRow('Trim Whitespace',   _trimLines,   (v) => setState(() => _trimLines = v)),
            _switchRow('Ignore Case',       _ignoreCase,  (v) => setState(() => _ignoreCase = v)),
          ]),
        ),
        const SizedBox(height: 16),

        GradientButton(label: 'Sort Karo', icon: Icons.sort_outlined, onPressed: _sort),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Result (${_output.split(_sepChar == '\n' ? '\n' : RegExp(r',|;|\|')).length} items)',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Row(children: [
              IconButton(icon: const Icon(Icons.copy_outlined, size: 18), color: AppTheme.purple,
                  onPressed: () { Clipboard.setData(ClipboardData(text: _output)); showSnack('Copied!'); }),
              IconButton(icon: const Icon(Icons.south_outlined, size: 18), color: AppTheme.textSecondary,
                  tooltip: 'Input mein bhejo',
                  onPressed: () => setState(() { _inputCtrl.text = _output; _output = ''; })),
            ]),
          ]),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4))),
            child: SelectableText(_output,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.7)),
          ),
        ],
      ]),
    );
  }

  Widget _chip(String id, String label, IconData icon) {
    final sel = _sortMode == id;
    return GestureDetector(
      onTap: () => setState(() => _sortMode = id),
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: sel ? AppTheme.brandGradient : null,
          color: sel ? null : AppTheme.cardBg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: sel ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.rajdhani(
              color: sel ? Colors.white : AppTheme.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _sepChip(String id, String label) {
    final sel = _separator == id;
    return GestureDetector(
      onTap: () => setState(() => _separator = id),
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: sel ? AppTheme.brandGradient : null,
          color: sel ? null : AppTheme.cardBg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor)),
        child: Text(label, style: GoogleFonts.rajdhani(
            color: sel ? Colors.white : AppTheme.textSecondary,
            fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _switchRow(String label, bool val, ValueChanged<bool> onChanged) => SwitchListTile(
    value: val, onChanged: onChanged,
    activeColor: AppTheme.purple,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    title: Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
  );
}
