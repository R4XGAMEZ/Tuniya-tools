import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../base_tool_screen.dart';

class GameSessionTimerScreen extends BaseToolScreen {
  const GameSessionTimerScreen({super.key}) : super(toolId: 'game_session_timer');
  @override
  State<GameSessionTimerScreen> createState() => _GameSessionTimerScreenState();
}

class _GameSessionTimerScreenState extends BaseToolScreenState<GameSessionTimerScreen> {
  Timer? _timer;
  int _elapsed = 0; // seconds
  bool _running = false;
  String _currentGame = 'BGMI';
  int _breakInterval = 60; // minutes
  int _nextBreakIn = 60; // minutes countdown
  List<Map<String, dynamic>> _history = [];

  final List<String> _games = ['BGMI', 'Free Fire', 'COD Mobile', 'Valorant', 'PUBG PC', 'Other'];
  final List<int> _breakOptions = [30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('game_session_history') ?? '[]';
    if (!mounted) return;
    setState(() => _history = List<Map<String, dynamic>>.from(jsonDecode(raw)));
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_session_history', jsonEncode(_history));
  }

  void _startStop() {
    if (_running) {
      _timer?.cancel();
      if (!mounted) return;
      setState(() => _running = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsed++;
          // Break reminder every interval
          final elapsedMin = _elapsed ~/ 60;
          _nextBreakIn = _breakInterval - (elapsedMin % _breakInterval);
          if (_elapsed % (_breakInterval * 60) == 0 && _elapsed > 0) {
            showSnack('⏰ Break lo! ${_breakInterval} minute ho gaye — aankhein aur haath rest karo!');
          }
        });
      });
      setState(() => _running = true);
    }
  }

  void _reset() {
    if (_elapsed > 0) {
      // Save session
      _history.insert(0, {
        'game': _currentGame,
        'duration': _elapsed,
        'date': DateTime.now().toString().substring(0, 16),
      });
      if (_history.length > 20) _history.removeLast();
      _saveHistory();
    }
    _timer?.cancel();
    setState(() { _elapsed = 0; _running = false; _nextBreakIn = _breakInterval; });
  }

  String _fmt(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _fmtDur(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${secs % 60}s';
  }

  Color get _timerColor {
    if (!_running) return AppTheme.textSecondary;
    if (_elapsed > _breakInterval * 60) return AppTheme.red;
    return Colors.greenAccent;
  }

  @override
  Widget buildBody(BuildContext context) {
    final progress = _breakInterval > 0
        ? ((_elapsed % (_breakInterval * 60)) / (_breakInterval * 60)).clamp(0.0, 1.0)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Game selector
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Game Chuno', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _games.map((g) => GestureDetector(
                onTap: _running ? null : () => setState(() => _currentGame = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: _currentGame == g ? AppTheme.brandGradient : null,
                    color: _currentGame == g ? null : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _currentGame == g ? Colors.transparent : AppTheme.borderColor),
                  ),
                  child: Text(g, style: GoogleFonts.rajdhani(
                      color: _currentGame == g ? Colors.white : AppTheme.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Break interval selector
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Break Reminder (minutes)', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(children: _breakOptions.map((b) => Expanded(
              child: GestureDetector(
                onTap: _running ? null : () => setState(() { _breakInterval = b; _nextBreakIn = b; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    gradient: _breakInterval == b ? AppTheme.brandGradient : null,
                    color: _breakInterval == b ? null : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text('$b', textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(color: _breakInterval == b ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                ),
              ),
            )).toList()),
          ]),
        ),
        const SizedBox(height: 24),

        // Main timer display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.purple.withValues(alpha: 0.15),
              AppTheme.red.withValues(alpha: 0.08),
            ]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _running ? AppTheme.purple.withValues(alpha: 0.5) : AppTheme.borderColor),
          ),
          child: Column(children: [
            Text(_currentGame, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 8),
            Text(_fmt(_elapsed),
                style: GoogleFonts.orbitron(color: _timerColor, fontSize: 52, fontWeight: FontWeight.bold,
                    shadows: _running ? [Shadow(color: _timerColor.withValues(alpha: 0.5), blurRadius: 20)] : [])),
            const SizedBox(height: 16),

            // Break progress ring
            Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation(progress > 0.8 ? AppTheme.red : AppTheme.purple),
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$_nextBreakIn', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('min', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 10)),
              ]),
            ]),
            const SizedBox(height: 8),
            Text('Break tak', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 20),

        // Controls
        Row(children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _startStop,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppTheme.purple.withValues(alpha: 0.4), blurRadius: 16)],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(_running ? 'Pause' : 'Start Session',
                      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _elapsed > 0 ? _reset : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Icon(Icons.stop_rounded, color: _elapsed > 0 ? AppTheme.red : AppTheme.textSecondary, size: 22),
            ),
          ),
        ]),

        // Session history
        if (_history.isNotEmpty) ...[ 
          const SizedBox(height: 28),
          Text('Session History', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ..._history.take(5).map((s) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
            child: Row(children: [
              const Icon(Icons.sports_esports_outlined, color: Colors.purpleAccent, size: 16),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['game'] as String, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                Text(s['date'] as String, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
              ]),
              const Spacer(),
              Text(_fmtDur(s['duration'] as int),
                  style: GoogleFonts.orbitron(color: AppTheme.purple, fontSize: 13, fontWeight: FontWeight.bold)),
            ]),
          )),
        ],
      ]),
    );
  }
}
