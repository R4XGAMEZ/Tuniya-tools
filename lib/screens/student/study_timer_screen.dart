import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});
  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  Timer? _timer;
  int _focusMins = 25;
  int _breakMins = 5;
  int _secondsLeft = 25 * 60;
  bool _running = false;
  bool _isFocus = true;
  int _sessions = 0;

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        if (!mounted) return;
        setState(() {
          _running = false;
          if (_isFocus) { _sessions++; _isFocus = false; _secondsLeft = _breakMins * 60; }
          else { _isFocus = true; _secondsLeft = _focusMins * 60; }
        });
      }
    });
    if (!mounted) return;
    setState(() => _running = true);
  }

  void _pause() { _timer?.cancel(); setState(() => _running = false); }
  void _reset() {
    _timer?.cancel();
    setState(() { _running = false; _isFocus = true; _secondsLeft = _focusMins * 60; });
  }
  void _skip() {
    _timer?.cancel();
    setState(() {
      _running = false;
      if (_isFocus) { _sessions++; _isFocus = false; _secondsLeft = _breakMins * 60; }
      else { _isFocus = true; _secondsLeft = _focusMins * 60; }
    });
  }

  String get _timeStr {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  double get _progress {
    final total = (_isFocus ? _focusMins : _breakMins) * 60;
    return 1 - (_secondsLeft / total);
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = _isFocus ? AppTheme.purple : Colors.green;
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Study Timer (Pomodoro)', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 14)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Session counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 16, height: 16,
                decoration: BoxDecoration(color: i < _sessions % 4 ? AppTheme.purple : AppTheme.cardBg2, shape: BoxShape.circle),
              )),
            ),
            Text('Sessions: $_sessions', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 30),
            // Mode label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
              child: Text(_isFocus ? '🎯 Focus Time' : '☕ Break Time', style: GoogleFonts.rajdhani(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 30),
            // Timer circle
            SizedBox(
              width: 220, height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220, height: 220,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 10,
                      backgroundColor: AppTheme.cardBg2,
                      color: color,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_timeStr, style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 42, fontWeight: FontWeight.bold)),
                      Text(_isFocus ? 'Focus' : 'Break', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: _reset, icon: const Icon(Icons.refresh, color: AppTheme.textSecondary, size: 28)),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _running ? _pause : _start,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Icon(_running ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(onPressed: _skip, icon: const Icon(Icons.skip_next, color: AppTheme.textSecondary, size: 28)),
              ],
            ),
            const SizedBox(height: 30),
            // Settings
            if (!_running) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Focus: ${_focusMins}m', style: GoogleFonts.rajdhani(color: AppTheme.textPrimary)),
                        Expanded(child: Slider(value: _focusMins.toDouble(), min: 5, max: 60, divisions: 11, activeColor: AppTheme.purple,
                          onChanged: (v) => setState(() { _focusMins = v.toInt(); if (_isFocus) _secondsLeft = _focusMins * 60; }))),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Break: ${_breakMins}m ', style: GoogleFonts.rajdhani(color: AppTheme.textPrimary)),
                        Expanded(child: Slider(value: _breakMins.toDouble(), min: 1, max: 30, divisions: 29, activeColor: Colors.green,
                          onChanged: (v) => setState(() { _breakMins = v.toInt(); if (!_isFocus) _secondsLeft = _breakMins * 60; }))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
