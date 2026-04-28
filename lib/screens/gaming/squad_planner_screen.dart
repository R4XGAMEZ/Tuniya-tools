import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../base_tool_screen.dart';

class SquadPlannerScreen extends BaseToolScreen {
  const SquadPlannerScreen({super.key}) : super(toolId: 'squad_planner');
  @override
  State<SquadPlannerScreen> createState() => _SquadPlannerScreenState();
}

class _SquadPlannerScreenState extends BaseToolScreenState<SquadPlannerScreen> {
  int _tab = 0;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _strategies = [];

  final _nameCtrl = TextEditingController();
  final _uIdCtrl = TextEditingController();
  final _sessionCtrl = TextEditingController();
  final _stratCtrl = TextEditingController();

  final List<String> _roles = ['IGL', 'Sniper', 'Rusher', 'Support', 'Fragger', 'Scout', 'Driver'];
  String _selectedRole = 'IGL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _members = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('squad_members') ?? '[]'));
      _sessions = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('squad_sessions') ?? '[]'));
      _strategies = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('squad_strategies') ?? '[]'));
    });
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('squad_members', jsonEncode(_members));
    await prefs.setString('squad_sessions', jsonEncode(_sessions));
    await prefs.setString('squad_strategies', jsonEncode(_strategies));
  }

  void _addMember() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { setError('Naam dalo!'); return; }
    setError(null);
    if (!mounted) return;
    setState(() => _members.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name, 'role': _selectedRole,
      'uid': _uIdCtrl.text.trim(),
      'joined': DateTime.now().toString().substring(0, 10),
    }));
    _nameCtrl.clear(); _uIdCtrl.clear();
    _saveAll();
    showSnack('$name squad mein add ho gaya! 🎮');
  }

  void _addSession() {
    final text = _sessionCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sessions.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'note': text, 'date': DateTime.now().toString().substring(0, 16),
    }));
    _sessionCtrl.clear();
    _saveAll();
  }

  void _addStrategy() {
    final text = _stratCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _strategies.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'strat': text, 'date': DateTime.now().toString().substring(0, 10),
    }));
    _stratCtrl.clear();
    _saveAll();
  }

  void _copySquad() {
    final buf = StringBuffer();
    buf.writeln('🎮 My Squad (${_members.length} members)');
    for (final m in _members) {
      buf.writeln('  [${m["role"]}] ${m["name"]}${(m["uid"] as String).isNotEmpty ? " — UID: ${m["uid"]}" : ""}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    showSnack('Squad info copy ho gayi!');
  }

  static const _tabs = ['Squad', 'Sessions', 'Strategies'];
  static const _tabIcons = [Icons.group_outlined, Icons.calendar_today_outlined, Icons.military_tech_outlined];

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [
      Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
        child: Row(children: List.generate(_tabs.length, (i) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                gradient: _tab == i ? AppTheme.brandGradient : null,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(_tabIcons[i], size: 14, color: _tab == i ? Colors.white : AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(_tabs[i], style: GoogleFonts.rajdhani(color: _tab == i ? Colors.white : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ))),
      ),
      const SizedBox(height: 4),
      Expanded(child: IndexedStack(index: _tab, children: [_buildSquadTab(), _buildSessionsTab(), _buildStrategiesTab()])),
    ]);
  }

  Widget _buildSquadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          _pill('${_members.length}', 'Members', Icons.person_outline),
          const SizedBox(width: 8),
          _pill('${_members.where((m) => m["role"] == "IGL").length}', 'IGL', Icons.star_outline),
          const SizedBox(width: 8),
          Expanded(child: GestureDetector(
            onTap: _copySquad,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.copy_outlined, size: 14, color: Colors.purpleAccent),
                const SizedBox(width: 4),
                Text('Copy', style: GoogleFonts.rajdhani(color: Colors.purpleAccent, fontSize: 12)),
              ]),
            ),
          )),
        ]),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.purple.withValues(alpha: 0.3))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Member Add Karo', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _nameCtrl, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Player Name', isDense: true)),
            const SizedBox(height: 8),
            TextField(controller: _uIdCtrl, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'UID / Username (optional)', isDense: true)),
            const SizedBox(height: 10),
            Text('Role', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: _roles.map((r) => GestureDetector(
              onTap: () => setState(() => _selectedRole = r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: _selectedRole == r ? AppTheme.brandGradient : null,
                  color: _selectedRole == r ? null : AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(r, style: GoogleFonts.rajdhani(color: _selectedRole == r ? Colors.white : AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            )).toList()),
            const SizedBox(height: 12),
            GradientButton(label: 'Add Member', icon: Icons.person_add_outlined, onPressed: _addMember),
          ]),
        ),
        const SizedBox(height: 14),

        if (_members.isEmpty)
          _empty('Squad mein koi nahi', 'Member add karo upar se')
        else
          ..._members.map((m) => _MemberCard(member: m, onDelete: () {
            setState(() => _members.removeWhere((x) => x['id'] == m['id']));
            _saveAll();
          })),
      ]),
    );
  }

  Widget _buildSessionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: TextField(controller: _sessionCtrl, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Session plan (time, map, goal...)'))),
          const SizedBox(width: 8),
          GestureDetector(onTap: _addSession,
            child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add, color: Colors.white, size: 20))),
        ]),
        const SizedBox(height: 14),
        if (_sessions.isEmpty) _empty('Koi session plan nahi', 'Squad ka next session plan karo')
        else ..._sessions.map((s) => _NoteCard(text: s['note'] as String, date: s['date'] as String,
            icon: Icons.calendar_today_outlined, onDelete: () { setState(() => _sessions.removeWhere((x) => x['id'] == s['id'])); _saveAll(); })),
      ]),
    );
  }

  Widget _buildStrategiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: TextField(controller: _stratCtrl, maxLines: 2, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Strategy (rotation, drop spot, end zone...)'))),
          const SizedBox(width: 8),
          GestureDetector(onTap: _addStrategy,
            child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add, color: Colors.white, size: 20))),
        ]),
        const SizedBox(height: 14),
        if (_strategies.isEmpty) _empty('Koi strategy nahi', 'Winning strategies yahan save karo')
        else ..._strategies.map((s) => _NoteCard(text: s['strat'] as String, date: s['date'] as String,
            icon: Icons.military_tech_outlined, onDelete: () { setState(() => _strategies.removeWhere((x) => x['id'] == s['id'])); _saveAll(); })),
      ]),
    );
  }

  Widget _pill(String val, String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppTheme.purple),
      const SizedBox(width: 6),
      Text('$val $label', style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _empty(String t, String s) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.sports_esports_outlined, color: AppTheme.textSecondary, size: 44),
    const SizedBox(height: 10),
    Text(t, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 15)),
    Text(s, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
  ])));
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onDelete;
  const _MemberCard({required this.member, required this.onDelete});

  static const _roleColors = {
    'IGL': Color(0xFFFFD700), 'Sniper': Color(0xFF64B5F6), 'Rusher': Color(0xFFEF5350),
    'Support': Color(0xFF66BB6A), 'Fragger': Color(0xFFFF9800), 'Scout': Color(0xFF26C6DA), 'Driver': Color(0xFFAB47BC),
  };

  @override
  Widget build(BuildContext context) {
    final color = _roleColors[member['role']] ?? Colors.purpleAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.5))),
          child: Center(child: Text(member['name'].toString()[0].toUpperCase(),
              style: GoogleFonts.orbitron(color: color, fontSize: 16, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(member['name'] as String, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(member['role'] as String, style: GoogleFonts.rajdhani(color: color, fontSize: 10, fontWeight: FontWeight.w700))),
            if ((member['uid'] as String).isNotEmpty) ...[
              const SizedBox(width: 6),
              Text('UID: ${member["uid"]}', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 10)),
            ],
          ]),
        ])),
        IconButton(icon: Icon(Icons.delete_outline, size: 16, color: AppTheme.red), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      ]),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String text, date;
  final IconData icon;
  final VoidCallback onDelete;
  const _NoteCard({required this.text, required this.date, required this.icon, required this.onDelete});
  @override
  void dispose() {
    _nameCtrl.dispose();
    _uIdCtrl.dispose();
    _sessionCtrl.dispose();
    _stratCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppTheme.purple, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
          const SizedBox(height: 2),
          Text(date, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 10)),
        ])),
        IconButton(icon: Icon(Icons.delete_outline, size: 16, color: AppTheme.red), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      ]),
    );
  }
}
