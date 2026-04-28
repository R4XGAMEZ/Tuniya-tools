import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class PdfMergerScreen extends BaseToolScreen {
  const PdfMergerScreen({super.key}) : super(toolId: 'pdf_merger');
  @override
  State<PdfMergerScreen> createState() => _PdfMergerScreenState();
}

class _PdfMergerScreenState extends BaseToolScreenState<PdfMergerScreen> {
  final List<_PdfEntry> _pdfs = [];
  final _outNameCtrl = TextEditingController(text: 'merged_document');
  String? _savedPath;

  Future<void> _addPdfs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null) return;
    setLoading(true);
    for (final f in result.files) {
      try {
        final doc = await PdfDocument.openFile(f.path!);
        if (!mounted) return;
        setState(() => _pdfs.add(_PdfEntry(
          path: f.path!,
          name: f.name,
          pages: doc.pagesCount,
        )));
        await doc.close();
      } catch (_) {
        if (!mounted) return;
        setState(() => _pdfs.add(_PdfEntry(path: f.path!, name: f.name, pages: 0)));
      }
    }
    if (mounted) setLoading(false);
    if (!mounted) return;
    setState(() => _savedPath = null);
  }

  void _remove(int i) => setState(() { _pdfs.removeAt(i); _savedPath = null; });

  void _reorder(int o, int n) {
    setState(() {
      if (n > o) n -= 1;
      final item = _pdfs.removeAt(o);
      _pdfs.insert(n, item);
      _savedPath = null;
    });
  }

  Future<void> _merge() async {
    if (_pdfs.length < 2) {
      setError('Kam se kam 2 PDFs select karo!');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      // Use pdf package to merge: copy all pages using raw bytes approach
      final merged = pw.Document();

      for (final entry in _pdfs) {
        final bytes = await File(entry.path).readAsBytes();
        // Embed each PDF as an image page (simple approach without pdf_manipulator)
        final doc = await PdfDocument.openData(bytes);
        for (int p = 1; p <= doc.pagesCount; p++) {
          final page = await doc.getPage(p);
          final img = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: PdfPageImageFormat.jpeg,
          );
          final pdfImg = pw.MemoryImage(img!.bytes);
          merged.addPage(pw.Page(
            pageFormat: PdfPageFormat(page.width, page.height),
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.Image(pdfImg, fit: pw.BoxFit.fill,
                width: page.width, height: page.height),
          ));
          await page.close();
        }
        await doc.close();
      }

      final dir = await getApplicationDocumentsDirectory();
      final safeName = _outNameCtrl.text.trim().isEmpty
          ? 'merged'
          : _outNameCtrl.text.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final file = File('${dir.path}/$safeName.pdf');
      await file.writeAsBytes(await merged.save());

      if (!mounted) return;
      setState(() => _savedPath = file.path);
      showSnack('${_pdfs.length} PDFs merge ho gayi! ✅');
    } catch (e) {
      setError('Error: $e');
    } finally {
      if (mounted) setLoading(false);
    }
  }

  int get _totalPages => _pdfs.fold(0, (s, e) => s + e.pages);

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add PDFs button
          OutlinedButton.icon(
            onPressed: _addPdfs,
            icon: const Icon(Icons.add_outlined),
            label: Text('PDFs Add Karo', style: GoogleFonts.rajdhani(fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.purple,
              side: BorderSide(color: AppTheme.purple.withValues(alpha: 0.5)),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),

          if (_pdfs.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_pdfs.length} PDFs • $_totalPages pages total',
                  style: GoogleFonts.rajdhani(
                      color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Drag to reorder',
                  style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 11)),
            ]),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 260),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: _pdfs.length,
                onReorder: _reorder,
                itemBuilder: (_, i) => ListTile(
                  key: ValueKey(_pdfs[i].path + i.toString()),
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  title: Text(_pdfs[i].name,
                      style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text('${_pdfs[i].pages} pages',
                      style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppTheme.red, size: 20),
                    onPressed: () => _remove(i),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Output name
          TextField(
            controller: _outNameCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Output File Name',
              prefixIcon: Icon(Icons.drive_file_rename_outline),
              suffixText: '.pdf',
            ),
          ),
          const SizedBox(height: 20),

          GradientButton(
            label: 'PDFs Merge Karo',
            icon: Icons.merge_outlined,
            onPressed: _merge,
            isLoading: isLoading,
          ),

          if (_savedPath != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.purple.withValues(alpha: 0.4)),
              ),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Merge complete! $_totalPages pages',
                      style: GoogleFonts.rajdhani(
                          color: Colors.greenAccent, fontWeight: FontWeight.w600))),
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
                    onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(_savedPath!)])),
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: Text('Share', style: GoogleFonts.rajdhani()),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.purple,
                        side: BorderSide(color: AppTheme.purple.withValues(alpha: 0.5))),
                  )),
                ]),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _PdfEntry {
  final String path, name;
  final int pages;
  _PdfEntry({required this.path, required this.name, required this.pages});
}
