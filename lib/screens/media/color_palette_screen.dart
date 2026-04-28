import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../base_tool_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ColorPaletteScreen extends BaseToolScreen {
  const ColorPaletteScreen({super.key}) : super(toolId: 'color_palette');
  @override
  State<ColorPaletteScreen> createState() => _ColorPaletteScreenState();
}

class _ColorPaletteScreenState extends BaseToolScreenState<ColorPaletteScreen> {
  String? errorMessage;
  File? _imageFile;
  List<Color> _colors = [];
  String? _copiedHex;

  Future<void> _pickImage(ImageSource src) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: src);
    if (picked == null) return;
    if (!mounted) return;
    setState(() { _imageFile = File(picked.path); _colors = []; });
    await _extractColors();
  }

  Future<void> _extractColors() async {
    if (_imageFile == null) return;
    setLoading(true);
    try {
      final bytes = await _imageFile!.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) { setError('Image load nahi hua.'); setLoading(false); return; }

      // Sample pixels from image
      final sampleCount = 5000;
      final w = image.width;
      final h = image.height;
      final rng = Random();
      final Map<int, int> colorFreq = {};

      for (int i = 0; i < sampleCount; i++) {
        final x = rng.nextInt(w);
        final y = rng.nextInt(h);
        final pixel = image.getPixel(x, y);
        // Quantize to reduce similar colors
        final pixel = img.getPixel(x, y); final r = (pixel.r.toInt() ~/ 32) * 32;
        final g = (pixel.g.toInt() ~/ 32) * 32;
        final b = (pixel.b.toInt() ~/ 32) * 32;
        final key = (r << 16) | (g << 8) | b;
        colorFreq[key] = (colorFreq[key] ?? 0) + 1;
      }

      // Sort by frequency, pick top 10
      final sorted = colorFreq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.take(10).map((e) {
        final r = (e.key >> 16) & 0xFF;
        final g = (e.key >> 8) & 0xFF;
        final b = e.key & 0xFF;
        return Color.fromRGBO(r, g, b, 1.0);
      }).toList();

      setState(() => _colors = top);
    } catch (e) { setError('Error: $e'); }
    setLoading(false);
  }

  String _toHex(Color c) => '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

  void _copy(Color c) {
    final hex = _toHex(c);
    Clipboard.setData(ClipboardData(text: hex));
    setState(() => _copiedHex = hex);
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _copiedHex = null); });
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Image preview or picker
        if (_imageFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
          )
        else
          Container(
            height: 200, width: double.infinity,
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.palette_outlined, color: AppTheme.purple, size: 48),
              const SizedBox(height: 8),
              Text('Image select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ]),
          ),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: Text('Gallery', style: GoogleFonts.inter()), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple, side: const BorderSide(color: AppTheme.borderColor), padding: const EdgeInsets.symmetric(vertical: 12)))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: Text('Camera', style: GoogleFonts.inter()), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple, side: const BorderSide(color: AppTheme.borderColor), padding: const EdgeInsets.symmetric(vertical: 12)))),
        ]),
        const SizedBox(height: 24),

        if (isLoading) ...[const CircularProgressIndicator(color: AppTheme.purple), const SizedBox(height: 8), Text('Colors extract ho rahe hain...', style: GoogleFonts.inter(color: AppTheme.textSecondary))],
        if (errorMessage != null) Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)),

        if (_colors.isNotEmpty) ...[
          if (_copiedHex != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('Copied: $_copiedHex', style: GoogleFonts.inter(color: Colors.green)),
          ),
          Text('${_colors.length} Colors Extracted', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          // Big palette strip
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(children: _colors.map((c) => Expanded(child: Container(height: 60, color: c))).toList()),
          ),
          const SizedBox(height: 16),
          // Individual color cards
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5),
            itemCount: _colors.length,
            itemBuilder: (_, i) {
              final c = _colors[i];
              final hex = _toHex(c);
              final isCopied = _copiedHex == hex;
              return GestureDetector(
                onTap: () => _copy(c),
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
                  child: Row(children: [
                    Container(width: 60, decoration: BoxDecoration(color: c, borderRadius: const BorderRadius.only(topLeft: Radius.circular(9), bottomLeft: Radius.circular(9)))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(hex, style: GoogleFonts.spaceMono(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('RGB(${c.red},${c.green},${c.blue})', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10)),
                    ])),
                    Padding(padding: const EdgeInsets.only(right: 8), child: Icon(isCopied ? Icons.check : Icons.copy_outlined, color: isCopied ? Colors.green : AppTheme.textSecondary, size: 16)),
                  ]),
                ),
              );
            },
          ),
        ],
      ]),
    );
  }
}
