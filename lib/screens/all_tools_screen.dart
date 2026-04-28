import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/tool_item.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';

class AllToolsScreen extends StatefulWidget {
  const AllToolsScreen({super.key});
  @override
  State<AllToolsScreen> createState() => _AllToolsScreenState();
}

class _AllToolsScreenState extends State<AllToolsScreen> {
  final _searchCtrl = TextEditingController();
  List<ToolItem> _displayed = ToolsData.all;
  ToolCategory? _filterCat;

  void _search(String q) {
    setState(() {
      var list = q.isEmpty ? ToolsData.all : ToolsData.search(q);
      if (_filterCat != null) list = list.where((t) => t.category == _filterCat).toList();
      _displayed = list;
    });
  }

  void _filterBy(ToolCategory? cat) {
    setState(() {
      _filterCat = cat;
      _search(_searchCtrl.text);
    });
  }

  void _openTool(ToolItem tool) {
    SettingsService().addRecentTool(tool.id);
    Navigator.pushNamed(context, tool.routeName);
  }
  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gradientAppBar('ALL TOOLS (${ToolsData.all.length})'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search tools...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () { _searchCtrl.clear(); _search(''); })
                    : null,
              ),
            ),
          ),
          // Category filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip(null, 'All'),
                ...ToolCategory.values.map((c) => _filterChip(c, ToolsData.categoryNames[c] ?? c.name)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${_displayed.length} tools',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _displayed.length,
              itemBuilder: (_, i) => ToolCard(
                tool: _displayed[i],
                onTap: () => _openTool(_displayed[i]),
              ).animate(delay: (i * 20).ms).fadeIn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(ToolCategory? cat, String label) {
    final selected = _filterCat == cat;
    return GestureDetector(
      onTap: () => _filterBy(cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.brandGradient : null,
          color: selected ? null : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : AppTheme.borderColor),
        ),
        child: Text(label,
            style: GoogleFonts.rajdhani(
                color: selected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
