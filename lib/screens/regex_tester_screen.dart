import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class RegexTesterScreen extends BaseToolScreen {
  const RegexTesterScreen({super.key}) : super(toolId: 'regex_tester');
  @override
  State<RegexTesterScreen> createState() => _RegexTesterScreenState();
}

class _RegexTesterScreenState extends BaseToolScreenState<RegexTesterScreen> {
  final _patternCtrl = TextEditingController();
  final _testCtrl    = TextEditingController();
  List<RegExpMatch> _matches = [];
  String _error = '';
  bool _flagI = false; // case insensitive
  bool _flagM = false; // multiline
  bool _flagS = false; // dotAll

  // Quick pattern templates
  static const _templates = [
    _Template('Email',        r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
    _Template('Phone (IN)',   r'[6-9]\d{9}'),
    _Template('URL',          r'https?://[^\s]+'),
    _Template('IP Address',   r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
    _Template('Date (DD/MM)', r'\d{2}/\d{2}/\d{4}'),
    _Template('Hex Color',    r'#[0-9a-fA-F]{3,6}'),
    _Template('Numbers Only', r'\d+'),
    _Template('Words Only',   r'\b[a-zA-Z]+\b'),
    _Template('Whitespace',   r'\s+'),
    _Template('HTML Tag',     r'<[^>]+>'),
  ];

  void _test() {
    final pattern = _patternCtrl.text;
    final text    = _testCtrl.text;
    if (pattern.isEmpty) { setState(() { _error = 'Pattern daalo!'; _matches = []; }); return; }
    if (text.isEmpty)    { setState(() { _error = 'Test string daalo!'; _matches = []; }); return; }
    try {
      final re = RegExp(
        pattern,
        caseSensitive: !_flagI,
        multiLine: _flagM,
        dotAll: _flagS,
      );
      setState(() { _error = ''; _matches = re.allMatches(text).toList(); });
    } catch (e) {
      setState(() { _error = 'Invalid pattern: $e'; _matches = []; });
    }
  }


  @override
  void dispose() {
    _patternCtrl.dispose();
    _testCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Pattern input
        Text('Pattern', style: GoogleFonts.rajdhani(
            color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _patternCtrl,
          style: GoogleFonts.sourceCodePro(color: const Color(0xFFFF7B72), fontSize: 14),
          decoration: InputDecoration(
            hintText: r'e.g. \d+  or  [a-z]+  or  (\w+@\w+\.\w+)',
            hintStyle: GoogleFonts.sourceCodePro(color: AppTheme.textSecondary, fontSize: 12),
            prefixText: '/',
            suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
              if (_patternCtrl.text.isNotEmpty)
                IconButton(icon: const Icon(Icons.clear, size: 16),
                    onPressed: () => setState(() { _patternCtrl.clear(); _matches = []; })),
            ]),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),

        // Flags
        Row(children: [
          _flagChip('i', 'Case insensitive', _flagI, (v) => setState(() => _flagI = v)),
          const SizedBox(width: 8),
          _flagChip('m', 'Multiline',        _flagM, (v) => setState(() => _flagM = v)),
          const SizedBox(width: 8),
          _flagChip('s', 'Dot matches all',  _flagS, (v) => setState(() => _flagS = v)),
        ]),
        const SizedBox(height: 12),

        // Quick templates
        Text('Quick Templates',
            style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() {
                _patternCtrl.text = _templates[i].pattern;
                _matches = [];
                _error = '';
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(_templates[i].name,
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Test string
        Text('Test String', style: GoogleFonts.rajdhani(
            color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _testCtrl,
          maxLines: 5,
          style: GoogleFonts.sourceCodePro(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Yahan text paste karo jisme pattern dhundna ho...',
            hintStyle: GoogleFonts.sourceCodePro(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        const SizedBox(height: 14),

        GradientButton(
          label: 'Test Karo',
          icon: Icons.search_outlined,
          onPressed: _test,
        ),

        if (_error.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.4)),
            ),
            child: Text(_error,
                style: GoogleFonts.rajdhani(color: Colors.redAccent, fontSize: 13)),
          ),
        ],

        if (_error.isEmpty && _matches.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
              const SizedBox(width: 8),
              Text('${_matches.length} match${_matches.length > 1 ? 'es' : ''} mili!',
                  style: GoogleFonts.rajdhani(color: Colors.greenAccent,
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 12),
          Text('Matches', style: GoogleFonts.rajdhani(
              color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...List.generate(_matches.length, (i) {
            final m = _matches[i];
            final groups = m.groupCount > 0
                ? List.generate(m.groupCount, (g) => m.group(g + 1) ?? 'null')
                : <String>[];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${i + 1}',
                      style: GoogleFonts.rajdhani(color: Colors.white,
                          fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('"${m.group(0)}"',
                      style: GoogleFonts.sourceCodePro(
                          color: const Color(0xFFFF7B72), fontSize: 13)),
                  Text('index: ${m.start}–${m.end}',
                      style: GoogleFonts.rajdhani(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  if (groups.isNotEmpty)
                    Text('groups: ${groups.join(', ')}',
                        style: GoogleFonts.rajdhani(
                            color: AppTheme.textSecondary, fontSize: 11)),
                ])),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  color: AppTheme.purple,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: m.group(0) ?? ''));
                    showSnack('Copied!');
                  },
                ),
              ]),
            );
          }),
        ],

        if (_error.isEmpty && _matches.isEmpty && _testCtrl.text.isNotEmpty
            && _patternCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.search_off_outlined, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Text('Koi match nahi mila!',
                  style: GoogleFonts.rajdhani(color: Colors.orange,
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _flagChip(String flag, String tooltip, bool active, ValueChanged<bool> onChanged) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => onChanged(!active),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: active ? AppTheme.brandGradient : null,
            color: active ? null : AppTheme.cardBg2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? Colors.transparent : AppTheme.borderColor),
          ),
          child: Text(flag, style: GoogleFonts.sourceCodePro(
              color: active ? Colors.white : AppTheme.textSecondary,
              fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _Template {
  final String name, pattern;
  const _Template(this.name, this.pattern);
}
