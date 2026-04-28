import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../base_tool_screen.dart';

class ClipReminderScreen extends BaseToolScreen {
  const ClipReminderScreen({super.key}) : super(toolId: 'clip_reminder');
  @override
  State<ClipReminderScreen> createState() => _ClipReminderScreenState();
}

class _ClipReminderScreenState extends BaseToolScreenState<ClipReminderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  bool _flashing = false;
  Timer? _flashTimer;

  List<Map<String, dynamic>> _clips = [];
  final _noteCtrl = TextEditingController();
  String _selectedGame = 'BGMI';
  String _clipType = 'Clutch';

  final List<String> _games = ['BGMI', 'Free Fire', 'COD Mobile', 'Valorant', 'PUBG PC', 'Other'];
  final List<String> _clipTypes = ['Clutch', 'Headshot', 'Knife Kill', 'Vehicle Kill', 'Long Range', 'Squad Wipe', 'Funny', 'Other'];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _loadClips();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _flashTimer?.cancel();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('clip_logs') ?? '[]';
    if (!mounted) return;
    setState(() => _clips = List<Map<String, dynamic>>.from(jsonDecode(raw)));
  }

  Future<void> _saveClips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clip_logs', jsonEncode(_clips));
  }

  void _triggerReminder() {
    // Vibrate
    HapticFeedback.heavyImpact();

    // Pulse animation
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());

    // Flash effect
    setState(() => _flashing = true);
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _flashing = false);
    });

    showSnack('🎬 CLIP RECORD KARO ABHI! Screenshot/Screen Record ON karo!');
  }

  void _logClip() {
    final clip = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'game': _selectedGame,
      'type': _clipType,
      'note': _noteCtrl.text.trim(),
      'time': DateTime.now().toString().substring(11, 16),
      'date': DateTime.now().toString().substring(0, 10),
    };
    setState(() { _clips.insert(0, clip); });
    _noteCtrl.clear();
    _saveClips();
    showSnack('Clip logged! 🎮 ${_clipType} — ${_selectedGame}');
  }

  void _deleteClip(String id) {
    setState(() => _clips.removeWhere((c) => c['id'] == id));
    _saveClips();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // BIG TRIGGER BUTTON
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: _flashing
                ? LinearGradient(colors: [Colors.red.shade700, Colors.orange])
                : AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (_flashing ? Colors.red : AppTheme.purple).withOpacity(0.6),
                blurRadius: _flashing ? 40 : 20,
                spreadRadius: _flashing ? 4 : 0,
              ),
            ],
          ),
          child: ScaleTransition(
            scale: _pulseAnim,
            child: GestureDetector(
              onTap: _triggerReminder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(children: [
                  Icon(Icons.videocam_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 10),
                  Text('CLIP RECORD KARO!',
                      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text('Ek tap = Alert + Vibration', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Clip log form
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderColor)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Clip Log Karo', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Game
            Text('Game', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _games.map((g) => GestureDetector(
                onTap: () => setState(() => _selectedGame = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: _selectedGame == g ? AppTheme.brandGradient : null,
                    color: _selectedGame == g ? null : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(g, style: GoogleFonts.rajdhani(
                      color: _selectedGame == g ? Colors.white : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              )).toList()),
            ),
            const SizedBox(height: 10),

            // Clip type
            Text('Clip Type', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _clipTypes.map((t) => GestureDetector(
                onTap: () => setState(() => _clipType = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _clipType == t ? AppTheme.purple.withOpacity(0.2) : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _clipType == t ? AppTheme.purple : AppTheme.borderColor),
                  ),
                  child: Text(t, style: GoogleFonts.rajdhani(
                      color: _clipType == t ? AppTheme.purple : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _noteCtrl,
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Note karo kya hua (optional)...'),
            ),
            const SizedBox(height: 12),
            GradientButton(label: 'Log Clip', icon: Icons.add_circle_outline, onPressed: _logClip),
          ]),
        ),

        // History
        if (_clips.isNotEmpty) ...[ 
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Clip History (${_clips.length})', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () { setState(() => _clips.clear()); _saveClips(); },
              child: Text('Clear All', style: GoogleFonts.rajdhani(color: AppTheme.red, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 8),
          ..._clips.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie_outlined, color: Colors.purpleAccent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${c["type"]} — ${c["game"]}',
                    style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                if ((c['note'] as String).isNotEmpty)
                  Text(c['note'] as String, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(c['time'] as String, style: GoogleFonts.orbitron(color: AppTheme.purple, fontSize: 11)),
                Text(c['date'] as String, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 10)),
              ]),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 16, color: AppTheme.red),
                onPressed: () => _deleteClip(c['id'] as String),
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
            ]),
          )),
        ],

        const SizedBox(height: 20),
        // Tips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('💡 Pro Tips', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...[
              'BGMI: Settings > Basic > Screen Recording',
              'COD: Built-in replay system use karo',
              'Free Fire: Replay option match ke baad milti hai',
              'Volume button shortcut set karo screen record ke liye',
            ].map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $t', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 11)),
            )),
          ]),
        ),
      ]),
    );
  }
}
