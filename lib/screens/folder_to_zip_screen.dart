import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class FolderToZipScreen extends BaseToolScreen {
  const FolderToZipScreen({super.key}) : super(toolId: 'folder_to_zip');
  @override
  State<FolderToZipScreen> createState() => _FolderToZipScreenState();
}

class _FolderToZipScreenState extends BaseToolScreenState<FolderToZipScreen> {
  // Flutter can't pick folders directly; pick multiple files from a folder instead
  final List<File> _files = [];
  final _zipNameCtrl = TextEditingController(text: 'my_archive');
  int _compressionLevel = 6; // 0=none, 9=max
  String? _savedPath;
  int _processedCount = 0;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    if (!mounted) return;
    setState(() {
      _files.clear();
      _files.addAll(result.files.map((f) => File(f.path!)));
      _savedPath = null;
    });
  }

  Future<void> _createZip() async {
    if (_files.isEmpty) {
      setError('Pehle files select karo!');
      return;
    }
    setLoading(true);
    setError(null);
    setState(() => _processedCount = 0);

    try {
      final archive = Archive();

      for (int i = 0; i < _files.length; i++) {
        final file = _files[i];
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(p.basename(file.path), bytes.length, bytes));
        if (!mounted) return;
        setState(() => _processedCount = i + 1);
      }

      final encoder = ZipEncoder();
      final zipBytes = encoder.encode(archive,
          level: _compressionLevel == 0 ? Deflate.NO_COMPRESSION : _compressionLevel);

      final dir = await getApplicationDocumentsDirectory();
      final safeName = _zipNameCtrl.text.trim().isEmpty
          ? 'archive'
          : _zipNameCtrl.text.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final file = File('${dir.path}/$safeName.zip');
      await file.writeAsBytes(zipBytes!);

      final originalSize = _files.fold<int>(0, (s, f) => s + f.lengthSync());
      final zipSize = await file.length();
      final ratio = originalSize > 0 ? (100 - (zipSize / originalSize * 100)).round() : 0;

      if (!mounted) return;
      setState(() => _savedPath = file.path);
      showSnack('ZIP ban gayi! $ratio% compression ✅');
    } catch (e) {
      setError('Error: $e');
    } finally {
      if (mounted) setLoading(false);
    }
  }

  String _compressionLabel(int level) {
    if (level == 0) return 'No Compression';
    if (level <= 2) return 'Fastest';
    if (level <= 5) return 'Normal';
    if (level <= 7) return 'Good';
    return 'Maximum';
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
            onTap: _pickFiles,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _files.isNotEmpty ? AppTheme.purple : AppTheme.borderColor,
                  width: _files.isNotEmpty ? 1.5 : 1,
                ),
              ),
              child: Column(children: [
                Icon(
                  _files.isNotEmpty ? Icons.folder_open_outlined : Icons.folder_outlined,
                  color: _files.isNotEmpty ? AppTheme.purple : AppTheme.textSecondary,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  _files.isNotEmpty
                      ? '${_files.length} files selected'
                      : 'Files select karo (ZIP mein aayenge)',
                  style: GoogleFonts.rajdhani(
                    color: _files.isNotEmpty ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontSize: 14, fontWeight: FontWeight.w600,
                  ),
                ),
                if (_files.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() { _files.clear(); _savedPath = null; }),
                    child: Text('Clear', style: GoogleFonts.rajdhani(color: AppTheme.red)),
                  ),
              ]),
            ),
          ),

          if (_files.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 140),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _files.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.insert_drive_file_outlined,
                      color: AppTheme.textSecondary, size: 16),
                  title: Text(p.basename(_files[i].path),
                      style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    _formatSize(_files[i].lengthSync()),
                    style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ZIP name
          TextField(
            controller: _zipNameCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'ZIP File Name',
              prefixIcon: Icon(Icons.folder_zip_outlined),
              suffixText: '.zip',
            ),
          ),
          const SizedBox(height: 16),

          // Compression level
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Compression Level',
                    style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
                Text(_compressionLabel(_compressionLevel),
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.purple, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
              Slider(
                value: _compressionLevel.toDouble(),
                min: 0, max: 9, divisions: 3,
                activeColor: AppTheme.purple,
                onChanged: (v) => setState(() => _compressionLevel = v.round()),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('No Compress', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 10)),
                Text('Maximum', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 10)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('$_processedCount / ${_files.length} files added...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 13)),
            ),

          GradientButton(
            label: 'ZIP Banao',
            icon: Icons.folder_zip_outlined,
            onPressed: _createZip,
            isLoading: isLoading,
          ),

          if (_savedPath != null) ...[
            const SizedBox(height: 16),
            Container(
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
                  Expanded(child: Text('ZIP tayar! Size: ${_formatSize(File(_savedPath!).lengthSync())}',
                      style: GoogleFonts.rajdhani(
                          color: Colors.greenAccent, fontWeight: FontWeight.w600))),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles([XFile(_savedPath!)]),
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: Text('Share ZIP', style: GoogleFonts.rajdhani()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.purple,
                      side: BorderSide(color: AppTheme.purple.withOpacity(0.5)),
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

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
