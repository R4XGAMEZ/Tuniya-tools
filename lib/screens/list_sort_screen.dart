import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class ListSortScreen extends BaseToolScreen {
  const ListSortScreen({super.key}) : super(toolId: 'list_sort');
  @override
  State<ListSortScreen> createState() => _ListSortScreenState();
}

class _ListSortScreenState extends BaseToolScreenState<ListSortScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String _mode = 'az';

  final _modes = [
    _SortMode('az',      'A → Z',           Icons.sort_by_alpha_outlined),
    _SortMode('za',      'Z → A',           Icons.sort_outlined),
    _SortMode('numAsc',  '0 → 9',           Icons.filter_1_outlined),
    _SortMode('numDesc', '9 → 0',           Icons.filter_9_plus_outlined),
    _SortMode('reverse', 'Reverse',         Icons.swap_vert_outlined),
    _SortMode('shuffle', 'Random Shuffle',  Icons.shuffle_outlined),
    _SortMode('dedup',   'Remove Dupes',    Icons.content_copy_outlined),
    _SortMode('unique',  'Unique + Sort',   Icons.auto_awesome_outlined),
    _SortMode('length',  'By Length ↑',     Icons.straighten_outlined),
    _SortMode('lenDesc', 'By Length ↓',     Icons.compress_outlined),
  ];

  void _sort() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) { setError('List paste karo pehle!'); return; }
    setError(null);

    List<String> items = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    switch (_mode) {
      case 'az':
        items.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      case 'za':
        items.sort((a, b) => b.toLowerCase().compareTo(a.toLowerCase()));
      case 'numAsc':
        items.sort((a, b) {
          final na = double.tryParse(a), nb = double.tryParse(b);
          if (na != null && nb != null) return na.compareTo(nb);
          return a.compareTo(b);
        });
      case 'numDesc':
        items.sort((a, b) {
          final na = double.tryParse(a), nb = double.tryParse(b);
          if (na != null && nb != null) return nb.compareTo(na);
          return b.compareTo(a);
        });
      case 'reverse':
        items = items.reversed.toList();
      case 'shuffle':
        items.shuffle();
      case 'dedup':
        final seen = <String>{};
        items = items.where((e) => seen.add(e.toLowerCase()) ? true : false).toList();
      case 'unique':
        final seen = <String>{};
        items = items.where((e) => seen.add(e.toLowerCase()) ? true : false).toList();
        items.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      case 'length':
        items.sort((a, b) => a.length.compareTo(b.length));
      case 'lenDesc':
        items.sort((a, b) => b.length.compareTo(a.length));
    }

    setState(() => _output = items.join('\n'));
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
            hintText: 'Ek line mein ek item likho...\nMangoes\nApples\nBananas',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() { _inputCtrl.clear(); _output = ''; }),
            ),
          ),
        ),
        const SizedBox(height: 14),

        Text('Sort Type Choose Karo',
            style: GoogleFonts.rajdhani(color: AppTheme.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _modes.map((m) {
            final sel = _mode == m.id;
            return GestureDetector(
              onTap: () => setState(() => _mode = m.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: sel ? AppTheme.brandGradient : null,
                  color: sel ? null : AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor),
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
          label: 'Sort Karo!',
          icon: Icons.sort_outlined,
          onPressed: _sort,
        ),

        if (_output.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Result (${_output.split('\n').length} items)',
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
              border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
            ),
            child: SelectableText(
              _output,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.7),
            ),
          ),
        ],
      ]),
    );
  }
}

class _SortMode {
  final String id, label;
  final IconData icon;
  const _SortMode(this.id, this.label, this.icon);
}
