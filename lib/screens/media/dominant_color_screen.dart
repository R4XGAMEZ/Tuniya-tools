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

class DominantColorScreen extends BaseToolScreen {
  const DominantColorScreen({super.key}) : super(toolId: 'dominant_color');
  @override
  State<DominantColorScreen> createState() => _DominantColorScreenState();
}

class _DominantColorScreenState extends BaseToolScreenState<DominantColorScreen> {
  File? _imageFile;
  Color? _dominantColor;
  List<Color> _palette = [];
  String? _copiedHex;

  Future<void> _pickImage(ImageSource src) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: src);
    if (picked == null) return;
    if (!mounted) return;
    setState(() { _imageFile = File(picked.path); _dominantColor = null; _palette = []; });
    await _analyze();
  }

  Future<void> _analyze() async {
    if (_imageFile == null) return;
    setLoading(true);
    try {
      final bytes = await _imageFile!.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) { setError('Image decode nahi hua.'); setLoading(false); return; }

      final rng = Random();
      final Map<int, int> freq = {};
      for (int i = 0; i < 8000; i++) {
        final x = rng.nextInt(image.width);
        final y = rng.nextInt(image.height);
        final pixel = image.getPixel(x, y);
        final r = (img.getRed(pixel) ~/ 16) * 16;
        final g = (img.getGreen(pixel) ~/ 16) * 16;
        final b = (img.getBlue(pixel) ~/ 16) * 16;
        final key = (r << 16) | (g << 8) | b;
        freq[key] = (freq[key] ?? 0) + 1;
      }

      final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final colors = sorted.take(6).map((e) {
        final r = (e.key >> 16) & 0xFF;
        final g = (e.key >> 8) & 0xFF;
        final b = e.key & 0xFF;
        return Color.fromRGBO(r, g, b, 1.0);
      }).toList();

      setState(() {
        _dominantColor = colors.first;
        _palette = colors;
      });
    } catch (e) { setError('Error: $e'); }
    setLoading(false);
  }

  String _toHex(Color c) =>
      '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

  String _colorName(Color c) {
    final r = c.red; final g = c.green; final b = c.blue;
    final max = [r, g, b].reduce((a, v) => a > v ? a : v);
    if (max < 50) return 'Black';
    if (r > 200 && g > 200 && b > 200) return 'White';
    if (r > g && r > b) return g > 150 ? 'Orange/Yellow' : 'Red';
    if (g > r && g > b) return 'Green';
    if (b > r && b > g) return r > 100 ? 'Purple/Violet' : 'Blue';
    if (r > 180 && g > 100 && b < 80) return 'Orange';
    return 'Gray/Mixed';
  }

  bool _isDark(Color c) => (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) < 128;

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
        // Image picker
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: _imageFile != null
              ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover))
              : Container(
                  height: 200, width: double.infinity,
                  decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.colorize_outlined, color: AppTheme.purple, size: 48),
                    const SizedBox(height: 8),
                    Text('Image select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                  ]),
                ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: Text('Gallery', style: GoogleFonts.inter()), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple, side: const BorderSide(color: AppTheme.borderColor), padding: const EdgeInsets.symmetric(vertical: 12)))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: Text('Camera', style: GoogleFonts.inter()), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple, side: const BorderSide(color: AppTheme.borderColor), padding: const EdgeInsets.symmetric(vertical: 12)))),
        ]),
        const SizedBox(height: 24),

        if (isLoading) ...[const CircularProgressIndicator(color: AppTheme.purple), const SizedBox(height: 8), Text('Colors analyze ho rahe hain...', style: GoogleFonts.inter(color: AppTheme.textSecondary))],
        if (errorMessage != null) Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)),

        if (_dominantColor != null) ...[
          // Dominant color big card
          GestureDetector(
            onTap: () => _copy(_dominantColor!),
            child: Container(
              width: double.infinity, height: 120,
              decoration: BoxDecoration(color: _dominantColor, borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Dominant Color', style: GoogleFonts.inter(color: _isDark(_dominantColor!) ? Colors.white70 : Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(_toHex(_dominantColor!), style: GoogleFonts.spaceMono(color: _isDark(_dominantColor!) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
                Text(_colorName(_dominantColor!), style: GoogleFonts.inter(color: _isDark(_dominantColor!) ? Colors.white70 : Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.copy_outlined, size: 14, color: _isDark(_dominantColor!) ? Colors.white70 : Colors.black54),
                  const SizedBox(width: 4),
                  Text('Tap to copy', style: GoogleFonts.inter(color: _isDark(_dominantColor!) ? Colors.white70 : Colors.black54, fontSize: 11)),
                ]),
              ]),
            ),
          ),
          if (_copiedHex != null) ...[
            const SizedBox(height: 6),
            Text('Copied: $_copiedHex', style: GoogleFonts.inter(color: Colors.green, fontSize: 12)),
          ],
          const SizedBox(height: 16),

          // Top colors palette
          Text('Top Colors', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 10),
          Row(children: _palette.map((c) => Expanded(child: GestureDetector(
            onTap: () => _copy(c),
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(_toHex(c).substring(1), style: GoogleFonts.spaceMono(color: _isDark(c) ? Colors.white70 : Colors.black54, fontSize: 8))),
            ),
          ))).toList()),
          const SizedBox(height: 16),

          // Color values
          Container(
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              _colorRow('HEX', _toHex(_dominantColor!)),
              _colorRow('RGB', 'rgb(${_dominantColor!.red}, ${_dominantColor!.green}, ${_dominantColor!.blue})'),
              _colorRow('Name', _colorName(_dominantColor!)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _colorRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 50, child: Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13))),
      Expanded(child: Text(value, style: GoogleFonts.spaceMono(color: AppTheme.textPrimary, fontSize: 13))),
      GestureDetector(onTap: () => _copy(_dominantColor!), child: const Icon(Icons.copy_outlined, color: AppTheme.purple, size: 16)),
    ]),
  );
}
