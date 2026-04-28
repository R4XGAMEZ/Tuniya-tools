import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/claude_service.dart';
import '../../widgets/common_widgets.dart';

class AiPdfSummarizerScreen extends StatefulWidget {
  const AiPdfSummarizerScreen({super.key});
  @override
  State<AiPdfSummarizerScreen> createState() => _AiPdfSummarizerScreenState();
}

class _AiPdfSummarizerScreenState extends State<AiPdfSummarizerScreen> {
  String? _fileName;
  String _pastedText = '';
  String _summary = '';
  bool _loading = false;
  bool _useTextMode = false;
  final _textCtrl = TextEditingController();

  @override
  void dispose() { _textCtrl.dispose(); super.dispose(); }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'txt']);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (!mounted) return;
      setState(() { _fileName = file.name; _summary = ''; });
      _showSnack('File selected: ${file.name}');
    } catch (e) {
      _showSnack('File pick nahi hui: $e', isError: true);
    }
  }

  Future<void> _summarize() async {
    if (!ClaudeService.instance.isReady) {
      _showSnack('Claude API key Settings mein daal do', isError: true); return;
    }
    final text = _useTextMode ? _textCtrl.text.trim() : _pastedText.trim();
    if (text.isEmpty && _fileName == null) {
      _showSnack('PDF ya text paste karo pehle!', isError: true); return;
    }
    final contentToSummarize = text.isNotEmpty ? text : 'File: $_fileName (Text extraction requires PDF library)';
    setState(() { _loading = true; _summary = ''; });
    try {
      final res = await ClaudeService.instance.summarizePdf(contentToSummarize);
      if (!mounted) return;
      setState(() => _summary = res);
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI PDF Summarizer', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!ClaudeService.instance.isReady) ApiWarningBanner(needsGemini: false, needsClaude: true),
          const SizedBox(height: 8),
          // Toggle mode
          Row(children: [
            Expanded(
              child: GestureDetector(
                onPressed: () => setState(() => _useTextMode = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: !_useTextMode ? AppTheme.brandGradient : null,
                    color: _useTextMode ? AppTheme.cardBg2 : null,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Center(child: Text('Paste Text', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14))),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onPressed: () => setState(() => _useTextMode = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: _useTextMode ? AppTheme.brandGradient : null,
                    color: !_useTextMode ? AppTheme.cardBg2 : null,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Center(child: Text('Type / Paste', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14))),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          if (!_useTextMode) ...[
            GestureDetector(
              onPressed: _pickPdf,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.purple.withOpacity(0.4), style: BorderStyle.solid),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.upload_file_outlined, color: AppTheme.purple, size: 40),
                  const SizedBox(height: 10),
                  Text(_fileName ?? 'PDF ya TXT file choose karo', style: GoogleFonts.rajdhani(color: _fileName != null ? AppTheme.textPrimary : AppTheme.textSecondary, fontSize: 14)),
                  if (_fileName == null) ...[
                    const SizedBox(height: 4),
                    Text('Tap karo file select karne ke liye', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Text('— Ya PDF ka text copy karke yahan paste karo —', textAlign: TextAlign.center, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
              maxLines: 5,
              onChanged: (v) => _pastedText = v,
              decoration: InputDecoration(
                hintText: 'PDF text paste karo yahan...',
                hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                filled: true, fillColor: AppTheme.cardBg2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
              ),
            ),
          ] else ...[
            TextField(
              controller: _textCtrl,
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Document content yahan paste karo jo summarize karna hai...',
                hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                filled: true, fillColor: AppTheme.cardBg2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.borderColor)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: _loading ? 'Summary ban rahi hai...' : 'Summarize with Claude 📋',
              onPressed: _summarize,
            ),
          ),
          if (_summary.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Summary', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
              GestureDetector(
                onPressed: () { Clipboard.setData(ClipboardData(text: _summary)); _showSnack('Copied!'); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.copy, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('Copy', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: SelectableText(_summary, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.6)),
            ),
          ],
        ]),
      ),
    );
  }
}
