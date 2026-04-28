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

class BatchImageCompressScreen extends BaseToolScreen {
  const BatchImageCompressScreen({super.key}) : super(toolId: 'batch_image_compressor');
  @override
  State<BatchImageCompressScreen> createState() => _BatchImageCompressScreenState();
}

class _BatchImageCompressScreenState extends BaseToolScreenState<BatchImageCompressScreen> {
  String? errorMessage;
  final List<File> _images = [];
  final Map<String, String> _status = {};
  int _quality = 70;
  int _done = 0;
  int _savedBytes = 0;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image);
    if (r == null) return;
    if (!mounted) return;
    setState(() {
      for (final f in r.files) {
        final file = File(f.path!);
        if (!_images.any((v) => v.path == file.path)) {
          _images.add(file);
          _status[f.path!] = 'Pending';
        }
      }
    });
  }

  Future<void> _compressAll() async {
    if (_images.isEmpty) { setError('Pehle images select karo!'); return; }
    setLoading(true); setError(null);
    setState(() { _done = 0; _savedBytes = 0; });
    final dir = (await getExternalStorageDirectory())!;
    final outDir = Directory(p.join(dir.path, 'TuniyaCompressed'));
    await outDir.create(recursive: true);

    for (final image in _images) {
      if (!mounted) return;
      setState(() => _status[image.path] = '⏳ Compressing...');
      try {
        final bytes = await image.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (!mounted) return;
        if (decoded == null) { setState(() => _status[image.path] = '❌ Decode failed'); continue; }
        final compressed = img.encodeJpg(decoded, quality: _quality);
        final out = p.join(outDir.path, '${p.basenameWithoutExtension(image.path)}_compressed.jpg');
        await File(out).writeAsBytes(compressed);
        final saved = bytes.length - compressed.length;
        if (!mounted) return;
        setState(() {
          _status[image.path] = '✅ ${_fmtSize(bytes.length)} → ${_fmtSize(compressed.length)}';
          _done++;
          _savedBytes += saved > 0 ? saved : 0;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _status[image.path] = '❌ Error');
      }
    }
    setLoading(false);
  }

  String _fmtSize(int b) {
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)}KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get _qualityLabel {
    if (_quality >= 90) return 'High Quality (zyada size)';
    if (_quality >= 70) return 'Balanced (recommended)';
    if (_quality >= 50) return 'Small Size (thoda blur)';
    return 'Very Small (noticeable loss)';
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            GestureDetector(
              onTap: isLoading ? null : _pick,
              child: Container(
                width: double.infinity, height: 90,
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor, width: 2)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_photo_alternate_outlined, color: AppTheme.purple, size: 28),
                  const SizedBox(height: 6),
                  Text('Images add karo (50+ ek saath)', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Quality slider
            Container(
              padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Quality: $_quality%', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                  Text(_qualityLabel, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                ]),
                Slider(value: _quality.toDouble(), min: 20, max: 95, divisions: 15, onChanged: isLoading ? null : (v) => setState(() => _quality = v.toInt()), activeColor: AppTheme.purple),
              ]),
            ),
            const SizedBox(height: 16),

            if (_images.isNotEmpty) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_images.length} Images', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                if (!isLoading) TextButton(onPressed: () => setState(() { _images.clear(); _status.clear(); _done = 0; _savedBytes = 0; }), child: Text('Clear', style: GoogleFonts.inter(color: AppTheme.red, fontSize: 12))),
              ]),
              ..._images.take(20).map((f) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.image_outlined, color: AppTheme.purple, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(p.basename(f.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  Text(_status[f.path] ?? '', style: GoogleFonts.inter(color: _status[f.path]?.contains('✅') == true ? Colors.green : _status[f.path]?.contains('❌') == true ? Colors.red : AppTheme.textSecondary, fontSize: 11)),
                ]),
              )),
              if (_images.length > 20) Text('...aur ${_images.length - 20} images', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
            ],

            if (isLoading) ...[LinearProgressIndicator(value: _images.isEmpty ? 0 : _done / _images.length), const SizedBox(height: 8), Text('$_done / ${_images.length} done...', style: GoogleFonts.inter(color: AppTheme.textSecondary))],
            if (!isLoading && _done > 0) Container(
              padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade700)),
              child: Column(children: [
                Text('$_done images compressed! 🎉', style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Total saved: ${_fmtSize(_savedBytes)}', style: GoogleFonts.inter(color: Colors.green.shade300, fontSize: 13)),
                const SizedBox(height: 4),
                Text('📁 TuniyaCompressed folder mein save hue', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
              ]),
            ),
            if (errorMessage != null) ...[const SizedBox(height: 8), Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red))],
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _compressAll,
            icon: const Icon(Icons.photo_size_select_small_outlined),
            label: Text(isLoading ? 'Compress ho raha hai...' : 'Sab Compress Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ),
    ]);
  }
}
