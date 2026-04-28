import 'package:share_plus/share_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../base_tool_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SlowedReverbScreen extends BaseToolScreen {
  const SlowedReverbScreen({super.key}) : super(toolId: 'slowed_reverb');
  @override
  State<SlowedReverbScreen> createState() => _SlowedReverbScreenState();
}

class _SlowedReverbScreenState extends BaseToolScreenState<SlowedReverbScreen> {
  File? _file;
  double _speed = 0.85;
  double _reverb = 0.5;
  bool _pitchCorrect = true;
  String? _outputPath;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (r == null) return;
    if (!mounted) return;
    setState(() { _file = File(r.files.single.path!); _outputPath = null; });
  }

  Future<void> _process() async {
    if (_file == null) { setError('Pehle audio file select karo!'); return; }
    setLoading(true); setError(null);
    try {
      final dir = await getTemporaryDirectory();
      final out = p.join(dir.path, 'slowed_${DateTime.now().millisecondsSinceEpoch}.mp3');
      final reverbWet = (_reverb * 0.8).toStringAsFixed(2);
      final reverbDry = (1.0 - _reverb * 0.5).toStringAsFixed(2);
      String af = 'atempo=$_speed';
      if (_pitchCorrect) af += ',asetrate=44100*$_speed,aresample=44100';
      af += ',aecho=0.8:$reverbWet:60:$reverbDry';
      final cmd = '-i "${_file!.path}" -af "$af" -b:a 192k "$out"';
      await // ffmpeg removed
      if (await File(out).exists()) {
        if (!mounted) return;
        setState(() => _outputPath = out);
      } else {
        setError('Process fail hua.');
      }
    } catch (e) { setError('Error: $e'); }
    setLoading(false);
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity, height: 100,
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _file != null ? AppTheme.purple : AppTheme.borderColor, width: 2)),
            child: _file == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.blur_on_outlined, color: AppTheme.purple, size: 32), const SizedBox(height: 6), Text('Audio file select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green, size: 28), const SizedBox(height: 4), Text(p.basename(_file!.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)]),
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            // Speed
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('🐢 Speed: ${_speed.toStringAsFixed(2)}x', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              Text(_speed < 0.8 ? 'Very Slow' : _speed < 0.9 ? 'Slow' : 'Normal', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
            ]),
            Slider(value: _speed, min: 0.5, max: 1.0, divisions: 10, onChanged: (v) => setState(() { _speed = v; _outputPath = null; }), activeColor: AppTheme.purple),
            const Divider(color: AppTheme.borderColor),
            const SizedBox(height: 8),
            // Reverb
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('🌊 Reverb: ${(_reverb * 100).toInt()}%', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              Text(_reverb < 0.3 ? 'Dry' : _reverb < 0.6 ? 'Medium' : 'Wet', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
            ]),
            Slider(value: _reverb, min: 0.1, max: 1.0, divisions: 9, onChanged: (v) => setState(() { _reverb = v; _outputPath = null; }), activeColor: AppTheme.red),
            const Divider(color: AppTheme.borderColor),
            const SizedBox(height: 8),
            // Pitch correction toggle
            SwitchListTile(
              title: Text('Pitch Correct karo (normal pitch maintain)', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13)),
              value: _pitchCorrect,
              onChanged: (v) => setState(() { _pitchCorrect = v; _outputPath = null; }),
              activeColor: AppTheme.purple,
              contentPadding: EdgeInsets.zero,
            ),
          ]),
        ),
        const SizedBox(height: 24),

        if (isLoading) ...[const LinearProgressIndicator(), const SizedBox(height: 8), Text('Processing ho raha hai...', style: GoogleFonts.inter(color: AppTheme.textSecondary)), const SizedBox(height: 16)],
        if (errorMessage != null) ...[Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)), const SizedBox(height: 12)],

        if (_outputPath != null) ...[
          Container(
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade700)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text('Slowed + Reverb ready! 🎵', style: GoogleFonts.inter(color: Colors.green))),
              ElevatedButton(onPressed: () => Share.shareXFiles([XFile(_outputPath!)]), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple), child: const Icon(Icons.share)),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        if (!isLoading) SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _process,
            icon: const Icon(Icons.blur_on),
            label: Text('Apply Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ]),
    );
  }
}
