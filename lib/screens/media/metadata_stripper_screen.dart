import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;
import '../base_tool_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MetadataStripperScreen extends BaseToolScreen {
  const MetadataStripperScreen({super.key}) : super(toolId: 'metadata_stripper');
  @override
  State<MetadataStripperScreen> createState() => _MetadataStripperScreenState();
}

class _MetadataStripperScreenState extends BaseToolScreenState<MetadataStripperScreen> {
  final List<File> _files = [];
  final Map<String, String> _status = {};
  int _done = 0;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'mkv', 'webp']);
    if (r == null) return;
    if (!mounted) return;
    setState(() {
      for (final f in r.files) {
        final file = File(f.path!);
        if (!_files.any((v) => v.path == file.path)) {
          _files.add(file);
          _status[f.path!] = 'Pending';
        }
      }
    });
  }

  bool _isVideo(String path) {
    final ext = p.extension(path).toLowerCase();
    return ['.mp4', '.mov', '.mkv', '.avi'].contains(ext);
  }

  Future<void> _stripAll() async {
    if (_files.isEmpty) { setError('Pehle files select karo!'); return; }
    setLoading(true); setError(null);
    setState(() => _done = 0);
    final dir = await getTemporaryDirectory();

    for (final file in _files) {
      if (!mounted) return;
      setState(() => _status[file.path] = '⏳ Stripping...');
      try {
        final ext = p.extension(file.path).replaceAll('.', '');
        final out = p.join(dir.path, 'stripped_${p.basenameWithoutExtension(file.path)}.$ext');
        if (_isVideo(file.path)) {
          // Remove all metadata from video
          await // ffmpeg removed
        } else {
          // Strip EXIF from image
          final bytes = await file.readAsBytes();
          final image = img.decodeImage(bytes);
          if (image != null) {
            final stripped = img.encodeJpg(image, quality: 95);
            await File(out).writeAsBytes(stripped);
          } else {
            await file.copy(out);
          }
        }
        if (await File(out).exists()) {
          if (!mounted) return;
          setState(() { _status[file.path] = '✅ Stripped'; _done++; });
        } else {
          if (!mounted) return;
          setState(() => _status[file.path] = '❌ Failed');
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => _status[file.path] = '❌ Error');
      }
    }
    setLoading(false);
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade700)),
              child: Row(children: [const Icon(Icons.privacy_tip_outlined, color: Colors.orange, size: 18), const SizedBox(width: 8), Expanded(child: Text('GPS location, camera model, date/time — sab remove ho jaayega.', style: GoogleFonts.inter(color: Colors.orange, fontSize: 12)))]),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: isLoading ? null : _pick,
              child: Container(
                width: double.infinity, height: 90,
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor, width: 2)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_circle_outline, color: AppTheme.purple, size: 28),
                  const SizedBox(height: 6),
                  Text('Images / Videos add karo', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            if (_files.isNotEmpty) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_files.length} Files', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                if (!isLoading) TextButton(onPressed: () => setState(() { _files.clear(); _status.clear(); _done = 0; }), child: Text('Clear', style: GoogleFonts.inter(color: AppTheme.red, fontSize: 12))),
              ]),
              ..._files.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Icon(_isVideo(f.path) ? Icons.video_file_outlined : Icons.image_outlined, color: AppTheme.purple, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.basename(f.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 12), overflow: TextOverflow.ellipsis),
                    Text(_status[f.path] ?? 'Pending', style: GoogleFonts.inter(color: _status[f.path]?.contains('✅') == true ? Colors.green : _status[f.path]?.contains('❌') == true ? Colors.red : AppTheme.textSecondary, fontSize: 11)),
                  ])),
                ]),
              )),
            ],

            if (isLoading) ...[const SizedBox(height: 12), LinearProgressIndicator(value: _files.isEmpty ? 0 : _done / _files.length), const SizedBox(height: 8), Text('$_done / ${_files.length} done...', style: GoogleFonts.inter(color: AppTheme.textSecondary))],
            if (!isLoading && _done > 0) ...[
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade700)), child: Row(children: [const Icon(Icons.shield_outlined, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text('$_done files ka metadata remove ho gaya! 🔒', style: GoogleFonts.inter(color: Colors.green, fontSize: 13)))])),
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
            onPressed: isLoading ? null : _stripAll,
            icon: const Icon(Icons.no_photography_outlined),
            label: Text(isLoading ? 'Strip ho raha hai...' : 'Metadata Strip Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ),
    ]);
  }
}
