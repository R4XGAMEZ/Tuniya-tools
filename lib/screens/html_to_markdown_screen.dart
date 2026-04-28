import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class HtmlToMarkdownScreen extends BaseToolScreen {
  const HtmlToMarkdownScreen({super.key}) : super(toolId: 'html_to_markdown');
  @override
  State<HtmlToMarkdownScreen> createState() => _HtmlToMarkdownScreenState();
}

class _HtmlToMarkdownScreenState extends BaseToolScreenState<HtmlToMarkdownScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  bool _cleanBlankLines = true;

  String _convert(String html) {
    String md = html;

    // --- Block elements ---
    // Headings
    for (int i = 6; i >= 1; i--) {
      md = md.replaceAllMapped(RegExp('<h$i[^>]*>(.*?)</h$i>', caseSensitive: false, dotAll: true),
          (m) => '\n${'#' * i} ${_strip(m.group(1) ?? '')}\n');
    }

    // Blockquote
    md = md.replaceAllMapped(RegExp(r'<blockquote[^>]*>(.*?)</blockquote>', caseSensitive: false, dotAll: true),
        (m) => '\n> ${_strip(m.group(1) ?? '').replaceAll('\n', '\n> ')}\n');

    // Pre / Code block
    md = md.replaceAllMapped(RegExp(r'<pre[^>]*><code[^>]*>(.*?)</code></pre>', caseSensitive: false, dotAll: true),
        (m) => '\n```\n${m.group(1) ?? ''}\n```\n');
    md = md.replaceAllMapped(RegExp(r'<pre[^>]*>(.*?)</pre>', caseSensitive: false, dotAll: true),
        (m) => '\n```\n${m.group(1) ?? ''}\n```\n');

    // Ordered list
    md = md.replaceAllMapped(RegExp(r'<ol[^>]*>(.*?)</ol>', caseSensitive: false, dotAll: true), (m) {
      int n = 1;
      String inner = m.group(1) ?? '';
      inner = inner.replaceAllMapped(RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true),
          (li) => '${n++}. ${_strip(li.group(1) ?? '')}\n');
      return '\n${_strip(inner)}\n';
    });

    // Unordered list
    md = md.replaceAllMapped(RegExp(r'<ul[^>]*>(.*?)</ul>', caseSensitive: false, dotAll: true), (m) {
      String inner = m.group(1) ?? '';
      inner = inner.replaceAllMapped(RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true),
          (li) => '- ${_strip(li.group(1) ?? '')}\n');
      return '\n${_strip(inner)}\n';
    });

    // Table (basic)
    md = md.replaceAllMapped(RegExp(r'<table[^>]*>(.*?)</table>', caseSensitive: false, dotAll: true), (m) {
      return '\n${_tableToMd(m.group(1) ?? '')}\n';
    });

    // Paragraph
    md = md.replaceAllMapped(RegExp(r'<p[^>]*>(.*?)</p>', caseSensitive: false, dotAll: true),
        (m) => '\n${_strip(m.group(1) ?? '')}\n');

    // HR
    md = md.replaceAll(RegExp(r'<hr[^>]*/?>',  caseSensitive: false), '\n---\n');

    // BR
    md = md.replaceAll(RegExp(r'<br[^>]*/?>',  caseSensitive: false), '\n');

    // --- Inline elements ---
    // Bold
    md = md.replaceAllMapped(RegExp(r'<(strong|b)[^>]*>(.*?)</(strong|b)>', caseSensitive: false, dotAll: true),
        (m) => '**${m.group(2)}**');

    // Italic
    md = md.replaceAllMapped(RegExp(r'<(em|i)[^>]*>(.*?)</(em|i)>', caseSensitive: false, dotAll: true),
        (m) => '_${m.group(2)}_');

    // Strikethrough
    md = md.replaceAllMapped(RegExp(r'<(s|del|strike)[^>]*>(.*?)</(s|del|strike)>', caseSensitive: false),
        (m) => '~~${m.group(2)}~~');

    // Inline code
    md = md.replaceAllMapped(RegExp(r'<code[^>]*>(.*?)</code>', caseSensitive: false),
        (m) => '`${m.group(1)}`');

    // Links
    md = md.replaceAllMapped(RegExp(r'<a[^>]*href=["\']([^"\']*)["\'][^>]*>(.*?)</a>', caseSensitive: false, dotAll: true),
        (m) => '[${_strip(m.group(2) ?? '')}](${m.group(1)})');

    // Images
    md = md.replaceAllMapped(RegExp(r'<img[^>]*src=["\']([^"\']*)["\'][^>]*alt=["\']([^"\']*)["\'][^>]*/?>',
        caseSensitive: false),
        (m) => '![${m.group(2)}](${m.group(1)})');
    md = md.replaceAllMapped(RegExp(r'<img[^>]*src=["\']([^"\']*)["\'][^>]*/?>',
        caseSensitive: false),
        (m) => '![image](${m.group(1)})');

    // Remove remaining tags
    md = md.replaceAll(RegExp(r'<[^>]+>'), '');

    // HTML entities
    md = md
        .replaceAll('&amp;',  '&')
        .replaceAll('&lt;',   '<')
        .replaceAll('&gt;',   '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;',  "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&mdash;','—')
        .replaceAll('&ndash;','–')
        .replaceAll('&hellip;','...')
        .replaceAll('&copy;', '©')
        .replaceAll('&reg;',  '®');

    if (_cleanBlankLines) {
      md = md.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    }

    return md.trim();
  }

  String _strip(String html) {
    return html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
  }

  String _tableToMd(String inner) {
    final rows = RegExp(r'<tr[^>]*>(.*?)</tr>', caseSensitive: false, dotAll: true)
        .allMatches(inner).toList();
    if (rows.isEmpty) return '';
    final lines = <String>[];
    bool headerDone = false;
    for (int i = 0; i < rows.length; i++) {
      final cells = RegExp(r'<t[dh][^>]*>(.*?)</t[dh]>', caseSensitive: false, dotAll: true)
          .allMatches(rows[i].group(1) ?? '')
          .map((c) => _strip(c.group(1) ?? '').replaceAll('|', '\\|'))
          .toList();
      lines.add('| ${cells.join(' | ')} |');
      if (!headerDone) {
        lines.add('| ${cells.map((_) => '---').join(' | ')} |');
        headerDone = true;
      }
    }
    return lines.join('\n');
  }

  void _run() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) { setError('HTML paste karo!'); return; }
    setError(null);
    setState(() => _output = _convert(text));
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
          style: GoogleFonts.sourceCodePro(color: const Color(0xFF79C0FF), fontSize: 12),
          decoration: InputDecoration(
            hintText: '<h1>Hello</h1>\n<p>Yahan <strong>HTML</strong> paste karo...</p>',
            hintStyle: GoogleFonts.sourceCodePro(color: AppTheme.textSecondary, fontSize: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() { _inputCtrl.clear(); _output = ''; }),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Row(children: [
          Checkbox(
            value: _cleanBlankLines,
            onChanged: (v) => setState(() => _cleanBlankLines = v ?? true),
            activeColor: AppTheme.purple,
          ),
          Text('Extra blank lines clean karo',
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
        ]),
        const SizedBox(height: 12),

        GradientButton(
          label: 'Markdown mein Convert Karo',
          icon: Icons.transform_outlined,
          onPressed: _run,
        ),

        // Supported tags info
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Wrap(spacing: 6, runSpacing: 4,
            children: ['h1-h6', 'p', 'strong/b', 'em/i', 'a', 'img', 'ul/ol/li',
              'code', 'pre', 'blockquote', 'table', 'hr', 'br', 'del/s']
              .map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.purple.withOpacity(0.3)),
                ),
                child: Text('<$tag>',
                    style: GoogleFonts.sourceCodePro(
                        color: AppTheme.purple, fontSize: 10)),
              )).toList()),
        ),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Markdown Output',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Row(children: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppTheme.purple,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _output));
                  showSnack('Markdown copy ho gaya!');
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
                  color: const Color(0xFFE6EDF3), fontSize: 12, height: 1.7),
            ),
          ),
        ],
      ]),
    );
  }
}
