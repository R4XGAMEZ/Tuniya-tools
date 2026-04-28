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

class BassBoosterScreen extends BaseToolScreen {
  const BassBoosterScreen({super.key}) : super(toolId: 'bass_booster');
  @override
  State<BassBoosterScreen> createState() => _BassBoosterScreenState();
}

class _BassBoosterScreenState extends BaseToolScreenState<BassBoosterScreen> {
  File? _file;
  double _bass = 10.0; // dB gain on low frequencies
  String _preset = 'Custom';
  String? _outputPath;

  final _presets = {
    'Light': 6.0,
    'Medium': 10.0,
    'Heavy': 16.0,
    'Extreme': 22.0,
    'Custom': -1.0,
  };

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (r == null) return;
    if (!mounted) return;
    setState(() { _file = File(r.files.single.path!); _outputPath = null; });
  }

  Future<void> _boost() async {
    if (_file == null) { setError('Pehle audio file select karo!'); return; }
    setLoading(true); setError(null);
    try {
      final dir = await getTemporaryDirectory();
      final ext = p.extension(_file!.path).replaceAll('.', '');
      final out = p.join(dir.path, 'bass_${DateTime.now().millisecondsSinceEpoch}.$ext');
      // equalizer: boost frequencies below 200Hz
      final cmd = '-i "${_file!.path}" -af "equalizer=f=60:width_type=o:width=2:g=${_bass.toInt()},equalizer=f=120:width_type=o:width=2:g=${(_bass * 0.7).toInt()},equalizer=f=200:width_type=o:width=2:g=${(_bass * 0.4).toInt()}" "$out"';
      await // ffmpeg removed
      if (await File(out).exists()) {
        if (!mounted) return;
        setState(() => _outputPath = out);
      } else {
        setError('Bass boost fail hua.');
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
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.graphic_eq_outlined, color: AppTheme.purple, size: 32), const SizedBox(height: 6), Text('Audio file select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green, size: 28), const SizedBox(height: 4), Text(p.basename(_file!.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)]),
          ),
        ),
        const SizedBox(height: 20),

        // Presets
        Text('Presets', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _presets.entries.map((e) {
          final sel = _preset == e.key;
          return GestureDetector(
            onTap: () => setState(() { _preset = e.key; if (e.value > 0) _bass = e.value; }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(gradient: sel ? AppTheme.brandGradient : null, color: sel ? null : AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor)),
              child: Text(e.key, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        }).toList()),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.graphic_eq, color: AppTheme.purple, size: 32),
              const SizedBox(width: 8),
              Text('Bass Gain: +${_bass.toInt()} dB', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            ]),
            const SizedBox(height: 12),
            Slider(value: _bass, min: 2, max: 25, divisions: 23, onChanged: (v) => setState(() { _bass = v; _preset = 'Custom'; }), activeColor: AppTheme.purple),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('+2 dB', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
              Text('+25 dB', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
            ]),
          ]),
        ),
        const SizedBox(height: 24),

        if (isLoading) ...[const LinearProgressIndicator(), const SizedBox(height: 8), Text('Bass boost ho raha hai...', style: GoogleFonts.inter(color: AppTheme.textSecondary)), const SizedBox(height: 16)],
        if (errorMessage != null) ...[Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)), const SizedBox(height: 12)],

        if (_outputPath != null) ...[
          Container(
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade700)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text('Bass boosted! 🔊', style: GoogleFonts.inter(color: Colors.green))),
              ElevatedButton(onPressed: () => Share.shareXFiles([XFile(_outputPath!)]), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple), child: const Icon(Icons.share)),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        if (!isLoading) SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _boost,
            icon: const Icon(Icons.graphic_eq),
            label: Text('Bass Boost Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ]),
    );
  }
}
