import 'package:share_plus/share_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class PdfToTextScreen extends BaseToolScreen {
  const PdfToTextScreen({super.key}) : super(toolId: 'pdf_to_text');
  @override
  State<PdfToTextScreen> createState() => _PdfToTextScreenState();
}

class _PdfToTextScreenState extends BaseToolScreenState<PdfToTextScreen> {
  String? _filePath;
  String? _fileName;
  String _extractedText = '';
  int _pageCount = 0;
  int _currentPage = 0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    if (!mounted) return;
    setState(() {
      _filePath = result.files.single.path;
      _fileName = result.files.single.name;
      _extractedText = '';
      _pageCount = 0;
      _currentPage = 0;
    });
  }

  Future<void> _extract() async {
    if (_filePath == null) {
      setError('Pehle PDF file select karo!');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      final doc = await PdfDocument.openFile(_filePath!);
      _pageCount = doc.pagesCount;
      final buffer = StringBuffer();

      for (int i = 1; i <= _pageCount; i++) {
        if (!mounted) return;
        setState(() => _currentPage = i);
        final page = await doc.getPage(i);
        
        if (pageText != null && pageText.isNotEmpty) {
          buffer.writeln('─── Page $i ───');
          buffer.writeln(pageText);
          buffer.writeln();
        }
        await page.close();
      }
      await doc.close();

      if (!mounted) return;
      setState(() => _extractedText = buffer.toString());
      if (_extractedText.trim().isEmpty) {
        setError('Koi text nahi mila — PDF mein scanned images ho sakti hain.');
      } else {
        showSnack('Text extract ho gaya! ✅');
      }
    } catch (e) {
      setError('Error: $e');
    } finally {
      if (mounted) setLoading(false);
    }
  }

  Future<void> _saveAsTxt() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final name = _fileName?.replaceAll('.pdf', '') ?? 'extracted';
      final file = File('${dir.path}/${name}_text.txt');
      await file.writeAsString(_extractedText);
      showSnack('TXT file save ho gayi!');
      Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      setError('Save error: $e');
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File picker card
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _filePath != null ? AppTheme.purple : AppTheme.borderColor,
                  width: _filePath != null ? 1.5 : 1,
                ),
              ),
              child: Column(children: [
                Icon(
                  _filePath != null ? Icons.picture_as_pdf : Icons.upload_file_outlined,
                  color: _filePath != null ? AppTheme.purple : AppTheme.textSecondary,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  _fileName ?? 'PDF file select karo',
                  style: GoogleFonts.rajdhani(
                    color: _filePath != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_filePath == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Tap to browse',
                        style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          if (isLoading && _pageCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Page $_currentPage / $_pageCount extract ho raha hai...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 13)),
            ),

          GradientButton(
            label: 'Text Extract Karo',
            icon: Icons.text_snippet_outlined,
            onPressed: _extract,
            isLoading: isLoading,
          ),

          if (_extractedText.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Extracted Text ($_pageCount pages)',
                  style: GoogleFonts.rajdhani(
                      color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  color: AppTheme.textSecondary,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _extractedText));
                    showSnack('Copy ho gaya!');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.save_alt_outlined, size: 18),
                  color: AppTheme.purple,
                  onPressed: _saveAsTxt,
                ),
              ]),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: SelectableText(
                _extractedText,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
