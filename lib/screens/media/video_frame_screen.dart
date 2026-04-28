import 'package:share_plus/share_plus.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../base_tool_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class VideoFrameScreen extends BaseToolScreen {
  const VideoFrameScreen({super.key}) : super(toolId: 'video_frame');
  @override
  State<VideoFrameScreen> createState() => _VideoFrameScreenState();
}

class _VideoFrameScreenState extends BaseToolScreenState<VideoFrameScreen> {
  String? errorMessage;
  File? _videoFile;
  double _atSec = 0;
  String _format = 'JPG';
  List<String> _frames = [];
  int _captureCount = 1;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.video);
    if (r == null) return;
    if (!mounted) return;
    setState(() { _videoFile = File(r.files.single.path!); _frames = []; });
  }

  Future<void> _capture() async {
    if (_videoFile == null) { setError('Pehle video select karo!'); return; }
    setLoading(true); setError(null);
    try {
      final dir = await getTemporaryDirectory();
      final ext = _format.toLowerCase();
      List<String> captured = [];
      for (int i = 0; i < _captureCount; i++) {
        final sec = _atSec + (i * 1.0);
        final out = p.join(dir.path, 'frame_${sec.toInt()}_${DateTime.now().millisecondsSinceEpoch}.$ext');
        final cmd = '-ss $sec -i "${_videoFile!.path}" -frames:v 1 -q:v 2 "$out"';
        await Process.run("sh", ["-c", cmd]);
        if (await File(out).exists()) captured.add(out);
      }
      if (!mounted) return;
      setState(() => _frames = captured);
      if (_frames.isEmpty) setError('Frame capture nahi hua.');
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
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _videoFile != null ? AppTheme.purple : AppTheme.borderColor, width: 2)),
            child: _videoFile == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.video_file_outlined, color: AppTheme.purple, size: 32), const SizedBox(height: 6), Text('Video select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green, size: 28), const SizedBox(height: 4), Text(p.basename(_videoFile!.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)]),
          ),
        ),
        const SizedBox(height: 20),

        Align(alignment: Alignment.centerLeft, child: Text('Timestamp: ${_atSec.toInt()}s', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13))),
        Slider(value: _atSec, min: 0, max: 300, divisions: 300, onChanged: (v) => setState(() => _atSec = v), activeColor: AppTheme.purple),

        Align(alignment: Alignment.centerLeft, child: Text('Kitne frames: $_captureCount', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13))),
        Slider(value: _captureCount.toDouble(), min: 1, max: 10, divisions: 9, onChanged: (v) => setState(() => _captureCount = v.toInt()), activeColor: AppTheme.purple),

        Align(alignment: Alignment.centerLeft, child: Text('Format', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13))),
        const SizedBox(height: 8),
        Row(children: ['JPG', 'PNG', 'WEBP'].map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _format = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(gradient: _format == f ? AppTheme.brandGradient : null, color: _format == f ? null : AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _format == f ? Colors.transparent : AppTheme.borderColor)),
              child: Text(f, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            ),
          ),
        )).toList()),
        const SizedBox(height: 24),

        if (isLoading) ...[const LinearProgressIndicator(), const SizedBox(height: 8), Text('Frames capture ho rahe hain...', style: GoogleFonts.inter(color: AppTheme.textSecondary)), const SizedBox(height: 16)],
        if (errorMessage != null) ...[Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)), const SizedBox(height: 12)],

        if (_frames.isNotEmpty) ...[
          Text('${_frames.length} Frames Ready ✅', style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: _frames.length,
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(children: [
                Image.file(File(_frames[i]), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                Positioned(bottom: 4, right: 4, child: GestureDetector(
                  onTap: () => Share.shareXFiles([XFile(_frames[i])]),
                  child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.purple, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.share, color: Colors.white, size: 16)),
                )),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => SharePlus.instance.share(ShareParams(files: _frames.map((f) => XFile(f)).toList())), icon: const Icon(Icons.share), label: Text('Sab Share Karo', style: GoogleFonts.inter()), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple, side: BorderSide(color: AppTheme.purple), padding: const EdgeInsets.symmetric(vertical: 13)))),
          const SizedBox(height: 16),
        ],

        if (!isLoading) SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _capture,
            icon: const Icon(Icons.photo_camera),
            label: Text('Frame Capture Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ]),
    );
  }
}
