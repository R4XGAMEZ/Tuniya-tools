import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import '../base_tool_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class VolumeBoosterScreen extends BaseToolScreen {
  const VolumeBoosterScreen({super.key}) : super(toolId: 'volume_booster');
  @override
  State<VolumeBoosterScreen> createState() => _VolumeBoosterScreenState();
}

class _VolumeBoosterScreenState extends BaseToolScreenState<VolumeBoosterScreen> {
  File? _file;
  double _gain = 2.0; // 1x = original, up to 5x
  String? _outputPath;

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
      final out = p.join(dir.path, 'boosted_${DateTime.now().millisecondsSinceEpoch}.$ext');
      final cmd = '-i "${_file!.path}" -af "volume=${_gain.toStringAsFixed(1)}" "$out"';
      await // ffmpeg removed
      if (await File(out).exists()) {
        if (!mounted) return;
        setState(() => _outputPath = out);
      } else {
        setError('Boost fail hua. File check karo.');
      }
    } catch (e) { setError('Error: $e'); }
    setLoading(false);
  }

  String get _gainLabel {
    if (_gain <= 1.0) return 'Original (${_gain.toStringAsFixed(1)}x)';
    if (_gain <= 2.0) return 'Soft Boost (${_gain.toStringAsFixed(1)}x)';
    if (_gain <= 3.0) return 'Medium (${_gain.toStringAsFixed(1)}x)';
    if (_gain <= 4.0) return 'Loud (${_gain.toStringAsFixed(1)}x)';
    return 'Max Boost (${_gain.toStringAsFixed(1)}x) ⚠️';
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
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.volume_up_outlined, color: AppTheme.purple, size: 32), const SizedBox(height: 6), Text('Audio file select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green, size: 28), const SizedBox(height: 4), Text(p.basename(_file!.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)]),
          ),
        ),
        const SizedBox(height: 32),

        // Volume knob visual
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Icon(Icons.volume_up, color: AppTheme.purple, size: 48),
            const SizedBox(height: 8),
            Text(_gainLabel, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Slider(value: _gain, min: 0.5, max: 5.0, divisions: 9, onChanged: (v) => setState(() { _gain = v; _outputPath = null; }), activeColor: _gain > 4 ? Colors.red : AppTheme.purple),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('0.5x', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
              Text('5x MAX', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        if (_gain > 4.0) Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade700)),
          child: Row(children: [const Icon(Icons.warning_amber, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text('Bahut zyada gain se audio distort ho sakta hai!', style: GoogleFonts.inter(color: Colors.red, fontSize: 12)))]),
        ),
        const SizedBox(height: 24),

        if (isLoading) ...[const LinearProgressIndicator(), const SizedBox(height: 8), Text('Volume boost ho raha hai...', style: GoogleFonts.inter(color: AppTheme.textSecondary)), const SizedBox(height: 16)],
        if (errorMessage != null) ...[Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)), const SizedBox(height: 12)],

        if (_outputPath != null) ...[
          Container(
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade700)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text('Volume boosted! 🔊', style: GoogleFonts.inter(color: Colors.green))),
              ElevatedButton(onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(_outputPath!)])), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple), child: const Icon(Icons.share)),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        if (!isLoading) SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _boost,
            icon: const Icon(Icons.volume_up),
            label: Text('Volume Boost Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ]),
    );
  }
}
