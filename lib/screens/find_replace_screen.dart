import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class FindReplaceScreen extends BaseToolScreen {
  const FindReplaceScreen({super.key}) : super(toolId: 'find_replace');
  @override
  State<FindReplaceScreen> createState() => _FindReplaceScreenState();
}

class _FindReplaceScreenState extends BaseToolScreenState<FindReplaceScreen> {
  final _inputCtrl  = TextEditingController();
  final _findCtrl   = TextEditingController();
  final _replCtrl   = TextEditingController();
  String _output    = '';
  int _matchCount   = 0;
  bool _caseSensitive = false;
  bool _useRegex      = false;
  bool _wholeWord     = false;

  void _doReplace() {
    final text = _inputCtrl.text;
    final find = _findCtrl.text;
    if (text.isEmpty) { setError('Text daalo!'); return; }
    if (find.isEmpty) { setError('Kya dhundhna hai?'); return; }
    setError(null);

    try {
      RegExp pattern;
      String finalFind = _useRegex ? find : RegExp.escape(find);
      if (_wholeWord && !_useRegex) finalFind = r'\b' + finalFind + r'\b';

      pattern = RegExp(finalFind,
          caseSensitive: _caseSensitive, multiLine: true);

      final matches = pattern.allMatches(text);
      final result  = text.replaceAll(pattern, _replCtrl.text);

      setState(() {
        _output     = result;
        _matchCount = matches.length;
      });

      if (matches.isEmpty) {
        showSnack('Koi match nahi mila!', isError: true);
      } else {
        showSnack('${matches.length} matches replace ho gaye ✅');
      }
    } catch (e) {
      setError('Regex error: $e');
    }
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _output));
    showSnack('Copy ho gaya!');
  }

  void _swapInputOutput() {
    setState(() {
      _inputCtrl.text = _output;
      _output = '';
      _matchCount = 0;
    });
  }


  @override
  void dispose() {
    _inputCtrl.dispose();
    _findCtrl.dispose();
    _replCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // Input text
        TextField(
          controller: _inputCtrl,
          maxLines: 6,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Input Text',
            alignLabelWithHint: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() {
                _inputCtrl.clear(); _output = ''; _matchCount = 0;
              }),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Find & Replace fields
        Row(children: [
          Expanded(child: TextField(
            controller: _findCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Find',
              prefixIcon: Icon(Icons.search_outlined),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: TextField(
            controller: _replCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Replace with',
              prefixIcon: Icon(Icons.find_replace_outlined),
            ),
          )),
        ]),
        const SizedBox(height: 14),

        // Options
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(children: [
            _toggle('Aa', 'Case Sensitive', _caseSensitive,
                (v) => setState(() => _caseSensitive = v)),
            const SizedBox(width: 8),
            _toggle('.*', 'Regex', _useRegex,
                (v) => setState(() => _useRegex = v)),
            const SizedBox(width: 8),
            _toggle('W', 'Whole Word', _wholeWord,
                (v) => setState(() => _wholeWord = v)),
          ]),
        ),
        const SizedBox(height: 16),

        GradientButton(
          label: 'Replace Karo',
          icon: Icons.find_replace_outlined,
          onPressed: _doReplace,
        ),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text('Result  ',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$_matchCount replaced',
                    style: GoogleFonts.rajdhani(
                        color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            Row(children: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppTheme.purple,
                onPressed: _copyOutput,
              ),
              IconButton(
                icon: const Icon(Icons.south_outlined, size: 18),
                color: AppTheme.textSecondary,
                tooltip: 'Input mein bhejo',
                onPressed: _swapInputOutput,
              ),
            ]),
          ]),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4)),
            ),
            child: SelectableText(
              _output,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.6),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _toggle(String label, String tooltip, bool value, ValueChanged<bool> onChanged) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: value ? AppTheme.brandGradient : null,
            color: value ? null : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: value ? Colors.transparent : AppTheme.borderColor),
          ),
          child: Column(children: [
            Text(label,
                style: GoogleFonts.orbitron(
                    color: value ? Colors.white : AppTheme.textSecondary,
                    fontSize: 11, fontWeight: FontWeight.bold)),
            Text(tooltip,
                style: GoogleFonts.rajdhani(
                    color: value ? Colors.white70 : AppTheme.textSecondary,
                    fontSize: 9),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
