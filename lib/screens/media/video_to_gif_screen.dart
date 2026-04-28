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

class VideoToGifScreen extends BaseToolScreen {
  const VideoToGifScreen({super.key}) : super(toolId: 'video_to_gif');
  @override
  State<VideoToGifScreen> createState() => _VideoToGifScreenState();
}

class _VideoToGifScreenState extends BaseToolScreenState<VideoToGifScreen> {
  String? errorMessage;
  File? _videoFile;
  String? _outputPath;
  double _startSec = 0;
  double _duration = 5;
  int _fps = 15;
  String _size = '480';

  final _fpsList = [8, 12, 15, 20, 24];
  final _sizeList = ['240', '320', '480', '640'];

  Future<void> _pickVideo() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.video);
    if (r == null) return;
    if (!mounted) return;
    setState(() { _videoFile = File(r.files.single.path!); _outputPath = null; });
  }

  Future<void> _convert() async {
    if (_videoFile == null) { setError('Pehle video select karo!'); return; }
    setLoading(true); setError(null);
    try {
      final dir = await getTemporaryDirectory();
      final out = p.join(dir.path, 'gif_${DateTime.now().millisecondsSinceEpoch}.gif');
      final cmd = '-ss ${_startSec.toInt()} -t ${_duration.toInt()} -i "${_videoFile!.path}" -vf "fps=$_fps,scale=$_size:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "$out"';
      await FFmpegKit.execute(cmd);
      if (await File(out).exists()) {
        if (!mounted) return;
        setState(() => _outputPath = out);
      } else {
        setError('GIF nahi bana. Video check karo.');
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
          onTap: _pickVideo,
          child: Container(
            width: double.infinity, height: 100,
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _videoFile != null ? AppTheme.purple : AppTheme.borderColor, width: 2)),
            child: _videoFile == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.video_file_outlined, color: AppTheme.purple, size: 32), const SizedBox(height: 6), Text('Video select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green, size: 28), const SizedBox(height: 4), Text(p.basename(_videoFile!.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)]),
          ),
        ),
        const SizedBox(height: 20),

        _label('Start Time: ${_startSec.toInt()}s'),
        Slider(value: _startSec, min: 0, max: 60, divisions: 60, onChanged: (v) => setState(() => _startSec = v), activeColor: AppTheme.purple),

        _label('Duration: ${_duration.toInt()}s'),
        Slider(value: _duration, min: 1, max: 15, divisions: 14, onChanged: (v) => setState(() => _duration = v), activeColor: AppTheme.purple),

        _label('FPS'),
        Wrap(spacing: 8, children: _fpsList.map((f) => _chip('$f FPS', _fps == f, () => setState(() => _fps = f))).toList()),
        const SizedBox(height: 12),

        _label('Width'),
        Wrap(spacing: 8, children: _sizeList.map((s) => _chip('${s}px', _size == s, () => setState(() => _size = s))).toList()),
        const SizedBox(height: 24),

        if (isLoading) ...[const LinearProgressIndicator(), const SizedBox(height: 8), Text('GIF ban raha hai...', style: GoogleFonts.inter(color: AppTheme.textSecondary)), const SizedBox(height: 16)],
        if (errorMessage != null) ...[Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)), const SizedBox(height: 12)],

        if (_outputPath != null) ...[
          Container(
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade700)),
            child: Column(children: [
              const Icon(Icons.gif_box_outlined, color: Colors.green, size: 40),
              const SizedBox(height: 6),
              Text('GIF Ready!', style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => Share.shareXFiles([XFile(_outputPath!)]), icon: const Icon(Icons.share), label: Text('Share / Save', style: GoogleFonts.inter()), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, padding: const EdgeInsets.symmetric(vertical: 13)))),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        if (!isLoading) SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.gif),
            label: Text('GIF Banao', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ]),
    );
  }

  Widget _label(String t) => Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13))));
  Widget _chip(String label, bool sel, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(gradient: sel ? AppTheme.brandGradient : null, color: sel ? null : AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor)),
      child: Text(label, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
    ),
  );
}
