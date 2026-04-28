import 'package:share/share.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../base_tool_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CircularCropScreen extends BaseToolScreen {
  const CircularCropScreen({super.key}) : super(toolId: 'circular_crop');
  @override
  State<CircularCropScreen> createState() => _CircularCropScreenState();
}

class _CircularCropScreenState extends BaseToolScreenState<CircularCropScreen> {
  String? errorMessage;
  File? _originalFile;
  File? _croppedFile;
  final _repaintKey = GlobalKey();

  Future<void> _pickImage(ImageSource src) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: src);
    if (picked == null) return;
    if (!mounted) return;
    setState(() { _originalFile = File(picked.path); _croppedFile = null; });
    await _crop(File(picked.path));
  }

  Future<void> _crop(File file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [AndroidUiSettings(toolbarTitle: 'Square Crop Karo', toolbarColor: AppTheme.purple, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: true)],
    );
    if (cropped == null) return;
    if (!mounted) return;
    setState(() => _croppedFile = File(cropped.path));
  }

  Future<void> _saveCircle() async {
    if (_croppedFile == null) return;
    setLoading(true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) { setError('Render error'); setLoading(false); return; }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) { setError('Capture fail'); setLoading(false); return; }
      final dir = await getTemporaryDirectory();
      final out = p.join(dir.path, 'circle_crop_${DateTime.now().millisecondsSinceEpoch}.png');
      await File(out).writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles([XFile(out)]);
    } catch (e) { setError('Error: $e'); }
    setLoading(false);
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: Text('Gallery', style: GoogleFonts.inter()), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple, side: const BorderSide(color: AppTheme.borderColor), padding: const EdgeInsets.symmetric(vertical: 13)))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: Text('Camera', style: GoogleFonts.inter()), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple, side: const BorderSide(color: AppTheme.borderColor), padding: const EdgeInsets.symmetric(vertical: 13)))),
        ]),
        const SizedBox(height: 24),

        if (_croppedFile != null) ...[
          Text('Preview', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Center(
            child: RepaintBoundary(
              key: _repaintKey,
              child: ClipOval(
                child: Image.file(_croppedFile!, width: 250, height: 250, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Tap "Save" to download circular PNG', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _crop(_originalFile!), icon: const Icon(Icons.crop), label: Text('Re-Crop', style: GoogleFonts.inter()), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple, side: const BorderSide(color: AppTheme.purple), padding: const EdgeInsets.symmetric(vertical: 13)))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(onPressed: isLoading ? null : _saveCircle, icon: const Icon(Icons.share), label: Text('Save/Share', style: GoogleFonts.inter(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, padding: const EdgeInsets.symmetric(vertical: 13)))),
          ]),
        ] else ...[
          Container(
            height: 250, width: 250,
            decoration: BoxDecoration(color: AppTheme.cardBg, shape: BoxShape.circle, border: Border.all(color: AppTheme.borderColor, width: 2)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.radio_button_checked_outlined, color: AppTheme.purple, size: 48),
              const SizedBox(height: 8),
              Text('Profile picture\ncircle crop', textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ]),
          ),
        ],

        if (isLoading) ...[const SizedBox(height: 16), const CircularProgressIndicator(color: AppTheme.purple)],
        if (errorMessage != null) ...[const SizedBox(height: 12), Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red))],
      ]),
    );
  }
}
