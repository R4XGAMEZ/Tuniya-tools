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

class BatchVideoToMp3Screen extends BaseToolScreen {
  const BatchVideoToMp3Screen({super.key}) : super(toolId: 'batch_video_to_mp3');
  @override
  State<BatchVideoToMp3Screen> createState() => _BatchVideoToMp3ScreenState();
}

class _BatchVideoToMp3ScreenState extends BaseToolScreenState<BatchVideoToMp3Screen> {
  final List<File> _videos = [];
  final Map<String, String> _status = {}; // filename -> status
  String _bitrate = '192k';
  bool _converting = false;
  int _done = 0;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.video);
    if (r == null) return;
    if (!mounted) return;
    setState(() {
      for (final f in r.files) {
        final file = File(f.path!);
        if (!_videos.any((v) => v.path == file.path)) {
          _videos.add(file);
          _status[f.path!] = 'Pending';
        }
      }
    });
  }

  Future<void> _convertAll() async {
    if (_videos.isEmpty) { setError('Pehle videos select karo!'); return; }
    setState(() { _converting = true; _done = 0; });
    setError(null);
    final dir = (await getExternalStorageDirectory())!;
    final outDir = Directory(p.join(dir.path, 'TuniyaMP3'));
    await outDir.create(recursive: true);

    for (final video in _videos) {
      if (!mounted) return;
      setState(() => _status[video.path] = '⏳ Converting...');
      try {
        final name = p.basenameWithoutExtension(video.path);
        final out = p.join(outDir.path, '$name.mp3');
        final cmd = '-i "${video.path}" -vn -acodec libmp3lame -b:a $_bitrate "$out"';
        await // ffmpeg removed
        if (await File(out).exists()) {
          if (!mounted) return;
          setState(() { _status[video.path] = '✅ Done'; _done++; });
        } else {
          if (!mounted) return;
          setState(() => _status[video.path] = '❌ Failed');
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => _status[video.path] = '❌ Error');
      }
    }
    setState(() => _converting = false);
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            GestureDetector(
              onTap: _converting ? null : _pick,
              child: Container(
                width: double.infinity, height: 90,
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor, width: 2)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_circle_outline, color: AppTheme.purple, size: 28),
                  const SizedBox(height: 6),
                  Text('Videos add karo (ek saath multiple)', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            if (_videos.isNotEmpty) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_videos.length} Videos', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                if (!_converting) TextButton(onPressed: () => setState(() { _videos.clear(); _status.clear(); _done = 0; }), child: Text('Clear', style: GoogleFonts.inter(color: AppTheme.red, fontSize: 12))),
              ]),
              ..._videos.map((v) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.video_file_outlined, color: AppTheme.purple, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.basename(v.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 12), overflow: TextOverflow.ellipsis),
                    Text(_status[v.path] ?? 'Pending', style: GoogleFonts.inter(color: _status[v.path]?.contains('✅') == true ? Colors.green : _status[v.path]?.contains('❌') == true ? Colors.red : AppTheme.textSecondary, fontSize: 11)),
                  ])),
                  if (!_converting) IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18), onPressed: () => setState(() { _videos.remove(v); _status.remove(v.path); })),
                ]),
              )),
              const SizedBox(height: 12),
            ],

            // Bitrate
            Row(children: [
              Text('Bitrate: ', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              ...['128k', '192k', '256k', '320k'].map((b) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: _converting ? null : () => setState(() => _bitrate = b),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(gradient: _bitrate == b ? AppTheme.brandGradient : null, color: _bitrate == b ? null : AppTheme.cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _bitrate == b ? Colors.transparent : AppTheme.borderColor)),
                    child: Text(b, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13)),
                  ),
                ),
              )),
            ]),

            if (_converting) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _videos.isEmpty ? 0 : _done / _videos.length),
              const SizedBox(height: 8),
              Text('$_done / ${_videos.length} done...', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ],

            if (!_converting && _done > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade700)),
                child: Row(children: [const Icon(Icons.folder_outlined, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text('$_done MP3 files saved in TuniyaMP3 folder! 🎵', style: GoogleFonts.inter(color: Colors.green, fontSize: 13)))]),
              ),
            ],

            if (errorMessage != null) ...[const SizedBox(height: 8), Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red))],
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _converting ? null : _convertAll,
            icon: const Icon(Icons.queue_music),
            label: Text(_converting ? 'Convert ho raha hai...' : 'Sab MP3 Banao', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ),
    ]);
  }
}
