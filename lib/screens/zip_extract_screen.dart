import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class ZipExtractScreen extends BaseToolScreen {
  const ZipExtractScreen({super.key}) : super(toolId: 'zip_extract');
  @override
  State<ZipExtractScreen> createState() => _ZipExtractScreenState();
}

class _ZipExtractScreenState extends BaseToolScreenState<ZipExtractScreen> {
  String? _filePath;
  String? _fileName;
  List<String> _entries = [];
  String? _outputDir;
  int _extracted = 0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null) return;
    if (!mounted) return;
    setState(() {
      _filePath = result.files.single.path;
      _fileName = result.files.single.name;
      _entries = [];
      _outputDir = null;
      _extracted = 0;
    });
    await _previewContents();
  }

  Future<void> _previewContents() async {
    if (_filePath == null) return;
    try {
      final bytes = await File(_filePath!).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      if (!mounted) return;
      setState(() => _entries = archive.map((f) => f.name).toList());
    } catch (e) {
      setError('ZIP preview error: $e');
    }
  }

  Future<void> _extract() async {
    if (_filePath == null) {
      setError('Pehle ZIP file select karo!');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folderName = _fileName!.replaceAll('.zip', '');
      final outDir = Directory('${dir.path}/$folderName');
      await outDir.create(recursive: true);

      final bytes = await File(_filePath!).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      int count = 0;

      for (final file in archive) {
        final outPath = '${outDir.path}/${file.name}';
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          count++;
          if (!mounted) return;
          setState(() => _extracted = count);
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }

      if (!mounted) return;
      setState(() => _outputDir = outDir.path);
      showSnack('$count files extract ho gayi! ✅');
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
                  _filePath != null ? Icons.folder_zip : Icons.upload_file_outlined,
                  color: _filePath != null ? AppTheme.purple : AppTheme.textSecondary,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  _fileName ?? 'ZIP file select karo',
                  style: GoogleFonts.rajdhani(
                    color: _filePath != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontSize: 14, fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          if (_entries.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Contents (${_entries.length} items)',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13,
                      fontWeight: FontWeight.w600)),
              if (isLoading)
                Text('$_extracted extracted...',
                    style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _entries.length,
                itemBuilder: (_, i) {
                  final e = _entries[i];
                  final isDir = e.endsWith('/');
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isDir ? Icons.folder_outlined : Icons.insert_drive_file_outlined,
                      color: isDir ? Colors.amber : AppTheme.textSecondary,
                      size: 18,
                    ),
                    title: Text(e,
                        style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          GradientButton(
            label: 'Extract Karo',
            icon: Icons.unarchive_outlined,
            onPressed: _extract,
            isLoading: isLoading,
          ),

          if (_outputDir != null) ...[
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
                  Expanded(child: Text('Extract complete! $_extracted files',
                      style: GoogleFonts.rajdhani(
                          color: Colors.greenAccent, fontWeight: FontWeight.w600))),
                ]),
                const SizedBox(height: 6),
                Text(_outputDir!,
                    style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => OpenFile.open(_outputDir!),
                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                    label: Text('Folder Open Karo', style: GoogleFonts.rajdhani()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.purple,
                      side: BorderSide(color: AppTheme.purple.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
