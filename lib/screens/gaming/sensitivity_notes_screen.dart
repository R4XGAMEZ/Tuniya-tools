import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../base_tool_screen.dart';

class SensitivityNotesScreen extends BaseToolScreen {
  const SensitivityNotesScreen({super.key}) : super(toolId: 'sensitivity_notes');
  @override
  State<SensitivityNotesScreen> createState() => _SensitivityNotesScreenState();
}

class _SensitivityNotesScreenState extends BaseToolScreenState<SensitivityNotesScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _showForm = false;

  // Form fields
  final _gameCtrl = TextEditingController();
  final _modeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final Map<String, TextEditingController> _fields = {};

  final List<String> _sensFields = [
    'General', 'ADS', 'Scope 2x', 'Scope 3x', 'Scope 4x', 'Scope 6x', 'Gyro',
  ];

  final List<String> _popularGames = [
    'BGMI', 'Free Fire', 'COD Mobile', 'Valorant', 'PUBG PC', 'CS:GO', 'Apex Legends', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    for (var f in _sensFields) {
      _fields[f] = TextEditingController();
    }
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sens_notes') ?? '[]';
    if (!mounted) return;
    setState(() => _entries = List<Map<String, dynamic>>.from(jsonDecode(raw)));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sens_notes', jsonEncode(_entries));
  }

  void _addEntry() {
    final game = _gameCtrl.text.trim();
    if (game.isEmpty) { setError('Game ka naam dalo!'); return; }
    setError(null);
    final Map<String, String> sens = {};
    for (var f in _sensFields) {
      final v = _fields[f]!.text.trim();
      if (v.isNotEmpty) sens[f] = v;
    }
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'game': game,
      'mode': _modeCtrl.text.trim(),
      'sens': sens,
      'notes': _notesCtrl.text.trim(),
      'date': DateTime.now().toString().substring(0, 16),
    };
    setState(() {
      _entries.insert(0, entry);
      _showForm = false;
    });
    _clearForm();
    _save();
    showSnack('Sensitivity save ho gayi! ✅');
  }

  void _clearForm() {
    _gameCtrl.clear(); _modeCtrl.clear(); _notesCtrl.clear();
    for (var c in _fields.values) c.clear();
  }

  void _deleteEntry(String id) {
    setState(() => _entries.removeWhere((e) => e['id'] == id));
    _save();
    showSnack('Delete ho gaya!', isError: true);
  }

  void _copyEntry(Map<String, dynamic> e) {
    final sens = e['sens'] as Map;
    final buf = StringBuffer();
    buf.writeln('🎮 ${e["game"]} — ${e["mode"]}');
    sens.forEach((k, v) => buf.writeln('  $k: $v'));
    if ((e['notes'] as String).isNotEmpty) buf.writeln('📝 ${e["notes"]}');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    showSnack('Copy ho gaya!');
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [
      // Header bar
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Text('${_entries.length} Presets',
              style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _showForm = !_showForm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(_showForm ? Icons.close : Icons.add, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(_showForm ? 'Cancel' : 'New Preset',
                    style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      ),

      if (_showForm) _buildForm(),

      Expanded(
        child: _entries.isEmpty && !_showForm
            ? _emptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: _entries.length,
                itemBuilder: (_, i) => _SensCard(
                  entry: _entries[i],
                  onDelete: () => _deleteEntry(_entries[i]['id']),
                  onCopy: () => _copyEntry(_entries[i]),
                ),
              ),
      ),
    ]);
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
      ),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Naya Sensitivity Preset', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Game name with quick picks
          Text('Game', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _popularGames.map((g) => GestureDetector(
              onTap: () => setState(() => _gameCtrl.text = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: _gameCtrl.text == g ? AppTheme.brandGradient : null,
                  color: _gameCtrl.text == g ? null : AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(g, style: GoogleFonts.rajdhani(
                    color: _gameCtrl.text == g ? Colors.white : AppTheme.textSecondary,
                    fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _gameCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Ya game ka naam type karo...'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _modeCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Mode (Classic/BR/Ranked/etc)'),
          ),
          const SizedBox(height: 14),

          Text('Sensitivity Values', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.8,
            children: _sensFields.map((f) => TextField(
              controller: _fields[f],
              keyboardType: TextInputType.number,
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: f,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
            )).toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Extra notes (device, config, tips...)'),
          ),
          const SizedBox(height: 14),
          GradientButton(label: 'Preset Save Karo', icon: Icons.save_outlined, onPressed: _addEntry),
        ]),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.tune_outlined, color: AppTheme.textSecondary, size: 52),
        const SizedBox(height: 12),
        Text('Koi preset nahi', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 16)),
        const SizedBox(height: 6),
        Text('+ New Preset tap karo apni sensitivity save karne ke liye',
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 13)),
      ]),
    );
  }
}

class _SensCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  const _SensCard({required this.entry, required this.onDelete, required this.onCopy});
  @override


  @override
  Widget build(BuildContext context) {
    final sens = (entry['sens'] as Map).cast<String, String>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.purple.withOpacity(0.2), Colors.transparent]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            const Icon(Icons.sports_esports_outlined, color: Colors.purpleAccent, size: 18),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry['game'] as String,
                  style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
              if ((entry['mode'] as String).isNotEmpty)
                Text(entry['mode'] as String,
                    style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
            ]),
            const Spacer(),
            Text(entry['date'] as String,
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 10)),
            const SizedBox(width: 4),
            IconButton(icon: const Icon(Icons.copy_outlined, size: 16, color: Colors.purpleAccent), onPressed: onCopy, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const SizedBox(width: 4),
            IconButton(icon: Icon(Icons.delete_outline, size: 16, color: AppTheme.red), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
        ),

        // Sensitivity grid
        if (sens.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: sens.entries.map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.purple.withOpacity(0.3)),
                ),
                child: RichText(text: TextSpan(children: [
                  TextSpan(text: '${e.key}: ', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
                  TextSpan(text: e.value, style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ])),
              )).toList(),
            ),
          ),

        if ((entry['notes'] as String).isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text('📝 ${entry["notes"]}',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 12)),
          )
        else
          const SizedBox(height: 4),
      ]),
    );
  }
}
