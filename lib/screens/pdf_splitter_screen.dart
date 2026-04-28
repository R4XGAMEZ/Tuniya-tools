import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' show PdfDocument, PdfPage, PdfPageImageFormat;
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class PdfSplitterScreen extends BaseToolScreen {
  const PdfSplitterScreen({super.key}) : super(toolId: 'pdf_splitter');
  @override
  State<PdfSplitterScreen> createState() => _PdfSplitterScreenState();
}

class _PdfSplitterScreenState extends BaseToolScreenState<PdfSplitterScreen> {
  String? _filePath, _fileName;
  int _totalPages = 0;
  String _splitMode = 'range'; // 'range', 'every', 'all'
  final _rangeCtrl = TextEditingController(text: '1-3, 5, 7-9');
  int _everyN = 1;
  List<String> _outputFiles = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    setLoading(true);
    try {
      final doc = await PdfDocument.openFile(result.files.single.path!);
      if (!mounted) return;
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
        _totalPages = doc.pagesCount;
        _outputFiles = [];
      });
      await doc.close();
    } catch (e) { setError('PDF open error: $e'); }
    finally { if (mounted) setLoading(false); }
  }

  List<List<int>> _parseRanges(String input) {
    final result = <List<int>>[];
    for (final part in input.split(',')) {
      final t = part.trim();
      if (t.contains('-')) {
        final sp = t.split('-');
        final s = int.tryParse(sp[0].trim()) ?? 1;
        final e = int.tryParse(sp[1].trim()) ?? _totalPages;
        result.add([s.clamp(1, _totalPages), e.clamp(1, _totalPages)]);
      } else {
        final n = int.tryParse(t);
        if (n != null && n >= 1 && n <= _totalPages) result.add([n, n]);
      }
    }
    return result;
  }

  List<List<int>> get _computedRanges {
    if (_splitMode == 'all') return List.generate(_totalPages, (i) => [i + 1, i + 1]);
    if (_splitMode == 'every') {
      final ranges = <List<int>>[];
      for (int i = 1; i <= _totalPages; i += _everyN) {
        ranges.add([i, (i + _everyN - 1).clamp(1, _totalPages)]);
      }
      return ranges;
    }
    return _parseRanges(_rangeCtrl.text);
  }

  Future<void> _split() async {
    if (_filePath == null) { setError('PDF select karo!'); return; }
    final ranges = _computedRanges;
    if (ranges.isEmpty) { setError('Valid range likho!'); return; }

    setLoading(true);
    setError(null);
    final outputs = <String>[];

    try {
      final srcBytes = await File(_filePath!).readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final baseName = _fileName!.replaceAll('.pdf', '');
      final outDir = Directory('${dir.path}/${baseName}_split');
      await outDir.create(recursive: true);

      for (int ri = 0; ri < ranges.length; ri++) {
        final range = ranges[ri];
        final from = range[0], to = range[1];
        final doc = await PdfDocument.openData(srcBytes);
        final newPdf = pw.Document();

        for (int p = from; p <= to; p++) {
          final page = await doc.getPage(p);
          final img = await page.render(
            width: page.width * 2, height: page.height * 2,
            format: PdfPageImageFormat.jpeg,
          );
          newPdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.Image(pw.MemoryImage(img!.bytes),
                fit: pw.BoxFit.fill, width: page.width, height: page.height),
          ));
          await page.close();
        }
        await doc.close();

        final outPath = '${outDir.path}/${baseName}_p${from}-${to}.pdf';
        await File(outPath).writeAsBytes(await newPdf.save());
        outputs.add(outPath);
      }

      if (!mounted) return;
      setState(() => _outputFiles = outputs);
      showSnack('${ranges.length} parts mein split ho gayi! ✅');
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
          // File picker
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _filePath != null ? AppTheme.purple : AppTheme.borderColor,
                  width: _filePath != null ? 1.5 : 1,
                ),
              ),
              child: Column(children: [
                Icon(_filePath != null ? Icons.picture_as_pdf : Icons.upload_file_outlined,
                    color: _filePath != null ? AppTheme.purple : AppTheme.textSecondary, size: 40),
                const SizedBox(height: 10),
                Text(_fileName ?? 'PDF select karo',
                    style: GoogleFonts.rajdhani(
                      color: _filePath != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 14, fontWeight: FontWeight.w600,
                    ), textAlign: TextAlign.center),
                if (_totalPages > 0)
                  Text('$_totalPages pages',
                      style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 12)),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Split mode
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Split Mode',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...[
                ('range', Icons.format_list_numbered_outlined, 'Custom Range (e.g. 1-3, 5)'),
                ('every', Icons.compare_outlined, 'Every N Pages'),
                ('all', Icons.call_split_outlined, 'Each Page Separately'),
              ].map((opt) => RadioListTile<String>(
                value: opt.$1,
                groupValue: _splitMode,
                onChanged: (v) => setState(() => _splitMode = v!),
                activeColor: AppTheme.purple,
                contentPadding: EdgeInsets.zero,
                title: Row(children: [
                  Icon(opt.$2, color: AppTheme.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text(opt.$3,
                      style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 12),

          if (_splitMode == 'range') ...[
            TextField(
              controller: _rangeCtrl,
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Page Ranges',
                hintText: '1-3, 5, 7-9',
                prefixIcon: Icon(Icons.format_list_numbered_outlined),
              ),
            ),
          ],

          if (_splitMode == 'every') ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Har $_everyN page(s) par split',
                      style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                  Text('${(_totalPages / _everyN).ceil()} parts',
                      style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 12)),
                ]),
                Slider(
                  value: _everyN.toDouble(), min: 1,
                  max: _totalPages > 0 ? _totalPages.toDouble() : 10,
                  divisions: _totalPages > 0 ? _totalPages - 1 : 9,
                  activeColor: AppTheme.purple,
                  onChanged: (v) => setState(() => _everyN = v.round()),
                ),
              ]),
            ),
          ],

          if (_splitMode == 'all' && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('$_totalPages alag-alag PDF files banegi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            ),

          const SizedBox(height: 16),

          GradientButton(
            label: 'PDF Split Karo',
            icon: Icons.call_split_outlined,
            onPressed: _split,
            isLoading: isLoading,
          ),

          if (_outputFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Output Files (${_outputFiles.length})',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._outputFiles.map((path) {
              final name = path.split('/').last;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(name,
                      style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    color: AppTheme.textSecondary,
                    onPressed: () => OpenFile.open(path),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 18),
                    color: AppTheme.purple,
                    onPressed: () => Share.shareXFiles([XFile(path)]),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                ]),
              );
            }),
          ],
        ],
      ),
    );
  }
}
