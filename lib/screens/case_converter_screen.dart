import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class CaseConverterScreen extends BaseToolScreen {
  const CaseConverterScreen({super.key}) : super(toolId: 'case_converter');
  @override
  State<CaseConverterScreen> createState() => _CaseConverterScreenState();
}

class _CaseConverterScreenState extends BaseToolScreenState<CaseConverterScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String _selectedMode = 'upper';

  final _modes = [
    _Mode('upper',     'UPPER CASE',      Icons.arrow_upward_outlined,     'HELLO WORLD'),
    _Mode('lower',     'lower case',      Icons.arrow_downward_outlined,   'hello world'),
    _Mode('title',     'Title Case',      Icons.title_outlined,            'Hello World'),
    _Mode('sentence',  'Sentence case',   Icons.short_text_outlined,       'Hello world'),
    _Mode('camel',     'camelCase',       Icons.code_outlined,             'helloWorld'),
    _Mode('pascal',    'PascalCase',      Icons.code_off_outlined,         'HelloWorld'),
    _Mode('snake',     'snake_case',      Icons.remove_outlined,           'hello_world'),
    _Mode('kebab',     'kebab-case',      Icons.horizontal_rule_outlined,  'hello-world'),
    _Mode('alternate', 'AlTeRnAtE cAsE',  Icons.swap_vert_outlined,        'hElLo WoRlD'),
    _Mode('reverse',   'esreveR',         Icons.undo_outlined,             'dlrow olleh'),
  ];

  void _convert() {
    final text = _inputCtrl.text;
    if (text.isEmpty) { setError('Kuch text likho!'); return; }
    setError(null);
    setState(() => _output = _applyMode(text, _selectedMode));
  }

  String _applyMode(String t, String mode) {
    switch (mode) {
      case 'upper': return t.toUpperCase();
      case 'lower': return t.toLowerCase();
      case 'title': return t.split(' ').map((w) =>
          w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
      case 'sentence':
        return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1).toLowerCase();
      case 'camel':
        final words = t.trim().split(RegExp(r'[\s_\-]+'));
        return words.isEmpty ? '' : words[0].toLowerCase() +
            words.skip(1).map((w) => w.isEmpty ? '' :
                w[0].toUpperCase() + w.substring(1).toLowerCase()).join('');
      case 'pascal':
        return t.trim().split(RegExp(r'[\s_\-]+')).map((w) =>
            w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join('');
      case 'snake':
        return t.trim().replaceAll(RegExp(r'[\s\-]+'), '_').toLowerCase();
      case 'kebab':
        return t.trim().replaceAll(RegExp(r'[\s_]+'), '-').toLowerCase();
      case 'alternate':
        return String.fromCharCodes(t.characters.toList().asMap().entries.map((e) =>
            e.key.isEven ? e.value.toUpperCase().codeUnitAt(0)
                         : e.value.toLowerCase().codeUnitAt(0)));
      case 'reverse': return t.split('').reversed.join('');
      default: return t;
    }
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
        // Input
        TextField(
          controller: _inputCtrl,
          maxLines: 5,
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Yahan text likho ya paste karo...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() { _inputCtrl.clear(); _output = ''; }),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Mode chips
        Text('Case Type Select Karo',
            style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _modes.map((m) {
            final sel = _selectedMode == m.id;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedMode = m.id);
                if (_inputCtrl.text.isNotEmpty) _convert();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: sel ? AppTheme.brandGradient : null,
                  color: sel ? null : AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? Colors.transparent : AppTheme.borderColor),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(m.icon, size: 14,
                      color: sel ? Colors.white : AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(m.label,
                      style: GoogleFonts.rajdhani(
                          color: sel ? Colors.white : AppTheme.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        GradientButton(
          label: 'Convert Karo',
          icon: Icons.transform_outlined,
          onPressed: _convert,
        ),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Result',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Row(children: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppTheme.purple,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _output));
                  showSnack('Copy ho gaya!');
                },
              ),
              IconButton(
                icon: const Icon(Icons.south_outlined, size: 18),
                color: AppTheme.textSecondary,
                tooltip: 'Input mein bhejo',
                onPressed: () => setState(() {
                  _inputCtrl.text = _output;
                  _output = '';
                }),
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
                  color: AppTheme.textPrimary, fontSize: 15, height: 1.6),
            ),
          ),
        ],
      ]),
    );
  }
}

class _Mode {
  final String id, label, example;
  final IconData icon;
  const _Mode(this.id, this.label, this.icon, this.example);
}
