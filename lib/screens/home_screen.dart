import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/tool_item.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';
import 'all_tools_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  List<ToolItem> _searchResults = [];
  bool _searching = false;
  int _selectedTab = 0;

  final List<ToolCategory> _tabs = [
    ToolCategory.ai,
    ToolCategory.file,
    ToolCategory.media,
    ToolCategory.downloader,
    ToolCategory.developer,
    ToolCategory.networking,
    ToolCategory.system,
    ToolCategory.utility,
    ToolCategory.codeEditor,
    ToolCategory.business,
    ToolCategory.lifestyle,
    ToolCategory.text,
    ToolCategory.gaming,
  ];

  void _onSearch(String q) {
    setState(() {
      _searching = q.isNotEmpty;
      _searchResults = ToolsData.search(q);
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
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _searching ? _buildSearchResults() : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildVoiceBtn(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
            child: Text('TUNIYA TOOLS',
                style: GoogleFonts.orbitron(
                    fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          const Spacer(),
          // API status dots
          _apiDot(SettingsService().hasGeminiKey, Colors.blue, 'G'),
          const SizedBox(width: 6),
          _apiDot(SettingsService().hasClaudeKey, AppTheme.red, 'C'),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _apiDot(bool active, Color color, String label) {
    return Tooltip(
      message: active ? 'API key set' : 'API key missing',
      child: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? color.withOpacity(0.15) : AppTheme.cardBg,
          border: Border.all(color: active ? color : AppTheme.borderColor),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.orbitron(
                  fontSize: 9, color: active ? color : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearch,
        style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Tools search karo... (e.g. "video compress")',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
          suffixIcon: _searching
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
                  onPressed: () { _searchCtrl.clear(); _onSearch(''); })
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text('Koi tool nahi mila',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (_, i) => ToolCard(
        tool: _searchResults[i],
        onTap: () => _openTool(_searchResults[i]),
      ).animate(delay: (i * 30).ms).fadeIn().slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildMainContent() {
    final recentIds = SettingsService().recentTools;
    final favIds = SettingsService().favTools;
    final recentTools = recentIds.map((id) => ToolsData.byId(id)).whereType<ToolItem>().toList();
    final favTools = favIds.map((id) => ToolsData.byId(id)).whereType<ToolItem>().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total tools count banner
          _buildStatsBanner(),

          // Favourites row
          if (favTools.isNotEmpty) ...[
            _sectionTitle('Favourites', Icons.star_outlined, AppTheme.red, onSeeAll: null),
            _horizontalToolRow(favTools),
          ],

          // Recent row
          if (recentTools.isNotEmpty) ...[
            _sectionTitle('Recently Used', Icons.history_outlined, AppTheme.purple, onSeeAll: null),
            _horizontalToolRow(recentTools),
          ],

          // Category tabs + grid
          _sectionTitle('Categories', Icons.grid_view_outlined, AppTheme.purple,
              onSeeAll: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AllToolsScreen()))),
          _buildCategoryTabs(),
          const SizedBox(height: 12),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.purple.withOpacity(0.15), AppTheme.red.withOpacity(0.1)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bannerStat('${ToolsData.all.length}', 'Tools'),
          _divider(),
          _bannerStat('${ToolsData.all.where((t) => t.isOffline).length}', 'Offline'),
          _divider(),
          _bannerStat('${ToolsData.all.where((t) => t.needsGemini || t.needsClaude).length}', 'AI Powered'),
        ],
      ),
    );
  }

  Widget _bannerStat(String val, String label) {
    return Column(
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
          child: Text(val, style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: AppTheme.borderColor);

  Widget _sectionTitle(String title, IconData icon, Color color,
      {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.rajdhani(
                  color: AppTheme.textPrimary, fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text('See All',
                  style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _horizontalToolRow(List<ToolItem> tools) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tools.length,
        itemBuilder: (_, i) {
          final t = tools[i];
          return GestureDetector(
            onTap: () => _openTool(t),
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(t.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(t.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rajdhani(
                          color: AppTheme.textPrimary, fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final selected = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected ? AppTheme.brandGradient : null,
                color: selected ? null : AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.transparent : AppTheme.borderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(ToolsData.categoryIcons[_tabs[i]]!,
                      color: selected ? Colors.white : AppTheme.textSecondary,
                      size: 14),
                  const SizedBox(width: 6),
                  Text(ToolsData.categoryNames[_tabs[i]]!,
                      style: GoogleFonts.rajdhani(
                          color: selected ? Colors.white : AppTheme.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final tools = ToolsData.byCategory(_tabs[_selectedTab]);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: tools.length,
      itemBuilder: (_, i) => ToolCard(
        tool: tools[i],
        onTap: () => _openTool(tools[i]),
      ).animate(delay: (i * 40).ms).fadeIn().slideY(begin: 0.15, end: 0),
    );
  }

  Widget _buildVoiceBtn() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppTheme.purple.withOpacity(0.5), blurRadius: 20)],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => Navigator.pushNamed(context, '/voice-assistant'),
        child: const Icon(Icons.mic_outlined, color: Colors.white),
      ),
    );
  }
}
