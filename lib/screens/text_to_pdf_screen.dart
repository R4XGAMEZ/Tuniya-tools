import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class TextToPdfScreen extends BaseToolScreen {
  const TextToPdfScreen({super.key}) : super(toolId: 'text_to_pdf');
  @override
  State<TextToPdfScreen> createState() => _TextToPdfScreenState();
}

class _TextToPdfScreenState extends BaseToolScreenState<TextToPdfScreen> {
  final _textCtrl = TextEditingController();
  final _titleCtrl = TextEditingController(text: 'My Document');
  double _fontSize = 12;
  String _pageSize = 'A4';
  String? _savedPath;

  final _pageSizes = ['A4', 'A3', 'Letter', 'Legal'];

  PdfPageFormat get _format {
    switch (_pageSize) {
      case 'A3': return PdfPageFormat.a3;
      case 'Letter': return PdfPageFormat.letter;
      case 'Legal': return PdfPageFormat.legal;
      default: return PdfPageFormat.a4;
    }
  }

  Future<void> _generate() async {
    if (_textCtrl.text.trim().isEmpty) {
      setError('Kuch text likho pehle!');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      final pdf = pw.Document();
      final title = _titleCtrl.text.trim().isEmpty ? 'Document' : _titleCtrl.text.trim();

      pdf.addPage(pw.MultiPage(
        pageFormat: _format,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Text(title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        build: (ctx) => [
          pw.SizedBox(height: 16),
          pw.Text(_textCtrl.text,
              style: pw.TextStyle(fontSize: _fontSize.roundToDouble())),
        ],
      ));

      final dir = await getApplicationDocumentsDirectory();
      final safeName = title.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final file = File('${dir.path}/${safeName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      setState(() => _savedPath = file.path);
      showSnack('PDF ban gayi! ✅');
    } catch (e) {
      setError('Error: $e');
    } finally {
      if (mounted) setLoading(false);
    }
  }


  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title field
          _label('Document Title'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'e.g. My Notes',
              prefixIcon: Icon(Icons.title_outlined),
            ),
          ),
          const SizedBox(height: 16),

          // Text area
          _label('Text Content'),
          const SizedBox(height: 6),
          TextField(
            controller: _textCtrl,
            maxLines: 12,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Yahan apna text likho ya paste karo...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          // Options Row
          Row(children: [
            Expanded(child: _optionCard(
              label: 'Page Size',
              child: DropdownButton<String>(
                value: _pageSize,
                dropdownColor: AppTheme.cardBg2,
                underline: const SizedBox(),
                isExpanded: true,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                items: _pageSizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _pageSize = v!),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: _optionCard(
              label: 'Font Size: ${_fontSize.round()}px',
              child: Slider(
                value: _fontSize,
                min: 8, max: 24,
                divisions: 8,
                activeColor: AppTheme.purple,
                onChanged: (v) => setState(() => _fontSize = v),
              ),
            )),
          ]),
          const SizedBox(height: 20),

          GradientButton(
            label: 'PDF Generate Karo',
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

  Widget _label(String text) => Text(text,
      style: GoogleFonts.rajdhani(
          color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600));

  Widget _optionCard({required String label, required Widget child}) {
    return Container(
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
  }

  Widget _resultCard() {
    return Container(
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
        const SizedBox(height: 6),
        Text(_savedPath!, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11),
            overflow: TextOverflow.ellipsis),
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
}
