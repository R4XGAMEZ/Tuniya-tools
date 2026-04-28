import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class SpeechPracticeScreen extends StatefulWidget {
  const SpeechPracticeScreen({super.key});
  @override
  State<SpeechPracticeScreen> createState() => _SpeechPracticeScreenState();
}

class _SpeechPracticeScreenState extends State<SpeechPracticeScreen> {
  final _textCtrl = TextEditingController();
  bool _teleprompterMode = false;
  bool _running = false;
  double _speed = 40.0; // pixels per second
  double _fontSize = 22.0;
  final _scrollCtrl = ScrollController();
  Timer? _timer;
  int _elapsed = 0;
  Timer? _clockTimer;

  void _startScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_scrollCtrl.hasClients) {
        final max = _scrollCtrl.position.maxScrollExtent;
        final current = _scrollCtrl.offset;
        if (current >= max) {
          _stopScroll();
        } else {
          _scrollCtrl.jumpTo(current + (_speed * 0.05));
        }
      }
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed++);
    });
    if (!mounted) return;
    setState(() => _running = true);
  }

  void _stopScroll() {
    _timer?.cancel();
    _clockTimer?.cancel();
    if (!mounted) return;
    setState(() => _running = false);
  }

  void _reset() {
    _stopScroll();
    if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
    if (!mounted) return;
    setState(() => _elapsed = 0);
  }

  String get _timeStr {
    final m = _elapsed ~/ 60;
    final s = _elapsed % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get _wordCount => _textCtrl.text.trim().isEmpty ? 0 : _textCtrl.text.trim().split(RegExp(r'\s+')).length;

  @override
  void dispose() {
    _timer?.cancel();
    _clockTimer?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Speech Practice', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_textCtrl.text.isNotEmpty)
            TextButton(
              onPressed: () => setState(() { _teleprompterMode = !_teleprompterMode; _reset(); }),
              child: Text(_teleprompterMode ? 'Edit' : 'Teleprompter', style: GoogleFonts.rajdhani(color: AppTheme.purple)),
            ),
        ],
      ),
      body: _teleprompterMode ? _buildTeleprompter() : _buildEditor(),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Speech / Script', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
              Text('$_wordCount words', style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _textCtrl,
                maxLines: null,
                expands: true,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.6),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Apna speech ya presentation script yahan likho ya paste karo...',
                  hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_textCtrl.text.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() { _teleprompterMode = true; _reset(); }),
                icon: const Icon(Icons.record_voice_over_outlined),
                label: Text('Start Teleprompter', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeleprompter() {
    return Column(
      children: [
        // Controls bar
        Container(
          color: AppTheme.cardBg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Speed: ${_speed.toInt()}', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                  Text('⏱ $_timeStr', style: GoogleFonts.orbitron(color: AppTheme.purple, fontSize: 14)),
                  Text('Size: ${_fontSize.toInt()}', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Slider(value: _speed, min: 10, max: 120, activeColor: Colors.orange, onChanged: (v) => setState(() => _speed = v))),
                  const SizedBox(width: 4),
                  Expanded(child: Slider(value: _fontSize, min: 16, max: 40, activeColor: AppTheme.purple, onChanged: (v) => setState(() => _fontSize = v))),
                ],
              ),
            ],
          ),
        ),
        // Text display
        Expanded(
          child: Container(
            color: Colors.black,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: MediaQuery.of(context).size.height * 0.3),
              child: Text(
                _textCtrl.text,
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: _fontSize, height: 1.8, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        // Play/Pause controls
        Container(
          color: AppTheme.cardBg,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: _reset, icon: const Icon(Icons.replay, color: AppTheme.textSecondary, size: 28)),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _running ? _stopScroll : _startScroll,
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: AppTheme.purple, shape: BoxShape.circle),
                  child: Icon(_running ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () => setState(() { _teleprompterMode = false; _reset(); }),
                icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 26),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
