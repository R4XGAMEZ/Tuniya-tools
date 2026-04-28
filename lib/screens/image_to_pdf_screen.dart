import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class ImageToPdfScreen extends BaseToolScreen {
  const ImageToPdfScreen({super.key}) : super(toolId: 'image_to_pdf');
  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends BaseToolScreenState<ImageToPdfScreen> {
  final List<File> _images = [];
  String _pageSize = 'A4';
  bool _fitToPage = true;
  String? _savedPath;

  final _imagePicker = ImagePicker();

  PdfPageFormat get _format {
    switch (_pageSize) {
      case 'A3': return PdfPageFormat.a3;
      case 'Letter': return PdfPageFormat.letter;
      default: return PdfPageFormat.a4;
    }
  }

  Future<void> _pickImages() async {
    final result = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (result.isNotEmpty) {
      if (!mounted) return;
      setState(() => _images.addAll(result.map((x) => File(x.path))));
    }
  }

  if (!mounted) return;
  void _removeImage(int index) => setState(() => _images.removeAt(index));

  void _reorder(int oldIdx, int newIdx) {
    setState(() {
      if (newIdx > oldIdx) newIdx -= 1;
      final item = _images.removeAt(oldIdx);
      _images.insert(newIdx, item);
    });
  }

  Future<void> _generate() async {
    if (_images.isEmpty) {
      setError('Kam se kam ek image toh add karo!');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      final pdf = pw.Document();

      for (final imgFile in _images) {
        final imgBytes = await imgFile.readAsBytes();
        final pdfImg = pw.MemoryImage(imgBytes);

        pdf.addPage(pw.Page(
          pageFormat: _format,
          margin: _fitToPage ? pw.EdgeInsets.zero : const pw.EdgeInsets.all(16),
          build: (ctx) => _fitToPage
              ? pw.Image(pdfImg, fit: pw.BoxFit.cover,
                  width: _format.width, height: _format.height)
              : pw.Center(child: pw.Image(pdfImg, fit: pw.BoxFit.contain)),
        ));
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/images_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      setState(() => _savedPath = file.path);
      showSnack('${_images.length} images ki PDF ban gayi! ✅');
    } catch (e) {
      setError('Error: $e');
    } finally {
      if (mounted) setLoading(false);
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add images button
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.purple, size: 28),
                const SizedBox(width: 12),
                Text('Images Add Karo',
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Image list (reorderable)
          if (_images.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_images.length} images (drag to reorder)',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
              TextButton.icon(
                onPressed: () => setState(() => _images.clear()),
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text('Clear All', style: GoogleFonts.rajdhani()),
                style: TextButton.styleFrom(foregroundColor: AppTheme.red),
              ),
            ]),
            SizedBox(
              height: 120,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                onReorder: _reorder,
                itemBuilder: (_, i) => Stack(
                  key: ValueKey(_images[i].path),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderColor),
                        image: DecorationImage(
                          image: FileImage(_images[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2, right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6, left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: Text('${i + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Options
          Row(children: [
            Expanded(child: _optCard(
              'Page Size',
              DropdownButton<String>(
                value: _pageSize,
                dropdownColor: AppTheme.cardBg2,
                underline: const SizedBox(),
                isExpanded: true,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                items: ['A4', 'A3', 'Letter']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _pageSize = v!),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: _optCard(
              'Image Fit',
              SwitchListTile(
                value: _fitToPage,
                onChanged: (v) => setState(() => _fitToPage = v),
                title: Text(_fitToPage ? 'Full Page' : 'With Margin',
                    style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                activeColor: AppTheme.purple,
                contentPadding: EdgeInsets.zero,
              ),
            )),
          ]),
          const SizedBox(height: 20),

          GradientButton(
            label: 'PDF Banao',
            icon: Icons.picture_as_pdf_outlined,
            onPressed: _generate,
            isLoading: isLoading,
          ),

          if (_savedPath != null) ...[
            const SizedBox(height: 16),
            _resultCard(),
          ],
        ],
      ),
    );
  }

  Widget _optCard(String label, Widget child) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
    decoration: BoxDecoration(
      color: AppTheme.cardBg2,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
        child,
      ],
    ),
  );

  Widget _resultCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.purple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
    ),
    child: Column(children: [
      Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text('PDF tayar hai!',
            style: GoogleFonts.rajdhani(color: Colors.greenAccent, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: () => OpenFile.open(_savedPath!),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: Text('Open', style: GoogleFonts.rajdhani()),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textPrimary,
              side: const BorderSide(color: AppTheme.borderColor)),
        )),
        const SizedBox(width: 10),
        Expanded(child: OutlinedButton.icon(
          onPressed: () => Share.shareXFiles([XFile(_savedPath!)]),
          icon: const Icon(Icons.share_outlined, size: 16),
          label: Text('Share', style: GoogleFonts.rajdhani()),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple,
              side: BorderSide(color: AppTheme.purple.withOpacity(0.5))),
        )),
      ]),
    ]),
  );
}
