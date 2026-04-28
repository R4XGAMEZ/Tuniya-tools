import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
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

class NoiseRemoverScreen extends BaseToolScreen {
  const NoiseRemoverScreen({super.key}) : super(toolId: 'noise_remover');
  @override
  State<NoiseRemoverScreen> createState() => _NoiseRemoverScreenState();
}

class _NoiseRemoverScreenState extends BaseToolScreenState<NoiseRemoverScreen> {
  String? errorMessage;
  File? _file;
  double _strength = 0.21;
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
      final ext = p.extension(_file!.path).replaceAll('.', '');
      final out = p.join(dir.path, 'denoised_${DateTime.now().millisecondsSinceEpoch}.$ext');
      // afftdn = FFmpeg noise reduction filter
      final cmd = '-i "${_file!.path}" -af "afftdn=nf=${(-(_strength * 97 + 3)).toInt()}" -b:a 192k "$out"';
      await FFmpegKit.execute(cmd);
      if (await File(out).exists()) {
        if (!mounted) return;
        setState(() => _outputPath = out);
      } else {
        setError('Noise removal fail hua.');
      }
    } catch (e) { setError('Error: $e'); }
    setLoading(false);
  }

  String get _strengthLabel {
    if (_strength < 0.3) return 'Light (Thoda noise hatao)';
    if (_strength < 0.6) return 'Medium (Balanced)';
    if (_strength < 0.85) return 'Strong (Zyada noise)';
    return 'Aggressive (Pura noise hatao)';
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
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.noise_control_off_outlined, color: AppTheme.purple, size: 32), const SizedBox(height: 6), Text('Audio file select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green, size: 28), const SizedBox(height: 4), Text(p.basename(_file!.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)]),
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.noise_control_off, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(_strengthLabel, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w500))),
            ]),
            const SizedBox(height: 12),
            Slider(value: _strength, min: 0.1, max: 1.0, divisions: 9, onChanged: (v) => setState(() { _strength = v; _outputPath = null; }), activeColor: Colors.green),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Light', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
              Text('Aggressive', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text('Zyada strength se voice bhi affect ho sakti hai. Medium try karo pehle.', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12))),
          ]),
        ),
        const SizedBox(height: 24),

        if (isLoading) ...[const LinearProgressIndicator(), const SizedBox(height: 8), Text('Noise remove ho raha hai...', style: GoogleFonts.inter(color: AppTheme.textSecondary)), const SizedBox(height: 16)],
        if (errorMessage != null) ...[Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)), const SizedBox(height: 12)],

        if (_outputPath != null) ...[
          Container(
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade700)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text('Noise remove ho gaya! ✨', style: GoogleFonts.inter(color: Colors.green))),
              ElevatedButton(onPressed: () => Share.shareXFiles([XFile(_outputPath!)]), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple), child: const Icon(Icons.share)),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        if (!isLoading) SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _process,
            icon: const Icon(Icons.noise_control_off),
            label: Text('Noise Remove Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ]),
    );
  }
}
