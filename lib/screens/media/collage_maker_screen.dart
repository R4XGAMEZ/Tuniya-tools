import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../base_tool_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CollageMakerScreen extends BaseToolScreen {
  const CollageMakerScreen({super.key}) : super(toolId: 'collage_maker');
  @override
  State<CollageMakerScreen> createState() => _CollageMakerScreenState();
}

class _CollageMakerScreenState extends BaseToolScreenState<CollageMakerScreen> {
  String? errorMessage;
  final List<File?> _slots = [null, null, null, null];
  String _layout = '2x2';
  Color _bgColor = Colors.black;
  final _repaintKey = GlobalKey();

  final _layouts = ['2x1', '1x2', '2x2', '3x1', '1+2'];
  final _bgColors = [Colors.black, Colors.white, Colors.grey.shade900, const Color(0xFF1A1A27)];

  Future<void> _pickSlot(int i) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _slots[i] = File(picked.path));
  }

  int get _slotCount {
    switch (_layout) {
      case '2x1': case '1x2': return 2;
      case '3x1': return 3;
      default: return 4;
    }
  }

  Future<void> _save() async {
    setLoading(true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) { setError('Render error'); setLoading(false); return; }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) { setError('Capture fail'); setLoading(false); return; }
      final dir = await getTemporaryDirectory();
      final out = p.join(dir.path, 'collage_${DateTime.now().millisecondsSinceEpoch}.png');
      await File(out).writeAsBytes(byteData.buffer.asUint8List());
      await SharePlus.instance.share(ShareParams(files: [XFile(out)]));
    } catch (e) { setError('Error: $e'); }
    setLoading(false);
  }

  Widget _slot(int i) => GestureDetector(
    onTap: () => _pickSlot(i),
    child: Container(
      decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.borderColor)),
      child: _slots[i] != null
          ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(_slots[i]!, fit: BoxFit.cover, width: double.infinity, height: double.infinity))
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_photo_alternate_outlined, color: AppTheme.purple, size: 28),
              const SizedBox(height: 4),
              Text('Tap', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
            ]),
    ),
  );

  Widget _buildCollagePreview() {
    const gap = 4.0;
    switch (_layout) {
      case '2x1':
        return Row(children: [Expanded(child: _slot(0)), const SizedBox(width: gap), Expanded(child: _slot(1))]);
      case '1x2':
        return Column(children: [Expanded(child: _slot(0)), const SizedBox(height: gap), Expanded(child: _slot(1))]);
      case '3x1':
        return Row(children: [Expanded(child: _slot(0)), const SizedBox(width: gap), Expanded(child: _slot(1)), const SizedBox(width: gap), Expanded(child: _slot(2))]);
      case '1+2':
        return Row(children: [
          Expanded(flex: 2, child: _slot(0)),
          const SizedBox(width: gap),
          Expanded(child: Column(children: [Expanded(child: _slot(1)), const SizedBox(height: gap), Expanded(child: _slot(2))])),
        ]);
      default: // 2x2
        return Column(children: [
          Expanded(child: Row(children: [Expanded(child: _slot(0)), const SizedBox(width: gap), Expanded(child: _slot(1))])),
          const SizedBox(height: gap),
          Expanded(child: Row(children: [Expanded(child: _slot(2)), const SizedBox(width: gap), Expanded(child: _slot(3))])),
        ]);
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Layout selector
        Text('Layout', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: _layouts.map((l) => GestureDetector(
          onTap: () => setState(() => _layout = l),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(gradient: _layout == l ? AppTheme.brandGradient : null, color: _layout == l ? null : AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _layout == l ? Colors.transparent : AppTheme.borderColor)),
            child: Text(l, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
          ),
        )).toList()),
        const SizedBox(height: 12),

        // BG color
        Text('Background Color', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Row(children: _bgColors.map((c) => GestureDetector(
          onTap: () => setState(() => _bgColor = c),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            width: 36, height: 36,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _bgColor == c ? AppTheme.purple : AppTheme.borderColor, width: _bgColor == c ? 3 : 1)),
          ),
        )).toList()),
        const SizedBox(height: 16),

        // Collage canvas
        RepaintBoundary(
          key: _repaintKey,
          child: Container(
            width: double.infinity, height: 320,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(12)),
            child: _buildCollagePreview(),
          ),
        ),
        const SizedBox(height: 16),

        if (errorMessage != null) ...[Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)), const SizedBox(height: 8)],
        if (isLoading) ...[const LinearProgressIndicator(), const SizedBox(height: 8)],

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _save,
            icon: const Icon(Icons.share),
            label: Text('Collage Save/Share Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ]),
    );
  }
}
