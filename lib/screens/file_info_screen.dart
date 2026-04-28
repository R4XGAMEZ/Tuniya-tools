import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class FileInfoScreen extends BaseToolScreen {
  const FileInfoScreen({super.key}) : super(toolId: 'file_info');
  @override
  State<FileInfoScreen> createState() => _FileInfoScreenState();
}

class _FileInfoScreenState extends BaseToolScreenState<FileInfoScreen> {
  File? _file;
  Map<String, String> _info = {};

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setLoading(true);
    setError(null);
    try {
      final file = File(result.files.single.path!);
      final stat = await file.stat();
      final size = stat.size;
      final name = p.basename(file.path);
      final ext = p.extension(file.path).toLowerCase();

      final info = <String, String>{
        'File Name': name,
        'Extension': ext.isEmpty ? '(none)' : ext,
        'File Type': _getType(ext),
        'Size': _formatSize(size),
        'Size (bytes)': '$size bytes',
        'Full Path': file.path,
        'Created': DateFormat('dd MMM yyyy, hh:mm a').format(stat.modified),
        'Modified': DateFormat('dd MMM yyyy, hh:mm a').format(stat.modified),
        'Permissions': stat.modeString(),
      };

      if (mounted) setState(() { _file = file; _info = info; });
    } catch (e) {
      if (mounted) setError('Error reading file: $e');
    } finally {
      if (mounted) setLoading(false);
    }
  }

  String _getType(String ext) {
    const map = {
      '.pdf': 'PDF Document',
      '.doc': 'Word Document', '.docx': 'Word Document',
      '.xls': 'Excel Sheet', '.xlsx': 'Excel Sheet',
      '.ppt': 'PowerPoint', '.pptx': 'PowerPoint',
      '.txt': 'Text File', '.md': 'Markdown',
      '.jpg': 'JPEG Image', '.jpeg': 'JPEG Image',
      '.png': 'PNG Image', '.gif': 'GIF Image', '.webp': 'WebP Image',
      '.mp3': 'MP3 Audio', '.aac': 'AAC Audio', '.wav': 'WAV Audio', '.flac': 'FLAC Audio',
      '.mp4': 'MP4 Video', '.mkv': 'MKV Video', '.avi': 'AVI Video', '.mov': 'MOV Video',
      '.zip': 'ZIP Archive', '.jar': 'JAR Archive', '.rar': 'RAR Archive', '.7z': '7-Zip Archive',
      '.apk': 'Android APK', '.aab': 'Android Bundle',
      '.json': 'JSON Data', '.xml': 'XML File', '.csv': 'CSV Data',
      '.dart': 'Dart Source', '.java': 'Java Source', '.py': 'Python Script',
      '.html': 'HTML File', '.css': 'CSS File', '.js': 'JavaScript',
    };
    return map[ext] ?? 'Unknown ($ext)';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  IconData _iconFor(String ext) {
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) return Icons.image_outlined;
    if (['.mp3', '.aac', '.wav', '.flac'].contains(ext)) return Icons.audiotrack_outlined;
    if (['.mp4', '.mkv', '.avi', '.mov'].contains(ext)) return Icons.video_file_outlined;
    if (['.pdf'].contains(ext)) return Icons.picture_as_pdf_outlined;
    if (['.zip', '.jar', '.rar', '.7z'].contains(ext)) return Icons.folder_zip_outlined;
    if (['.apk', '.aab'].contains(ext)) return Icons.android_outlined;
    return Icons.insert_drive_file_outlined;
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
                color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _file != null ? AppTheme.purple : AppTheme.borderColor,
                  width: _file != null ? 1.5 : 1,
                ),
              ),
              child: Column(children: [
                Icon(
                  _file != null
                      ? _iconFor(p.extension(_file!.path).toLowerCase())
                      : Icons.upload_file_outlined,
                  color: _file != null ? AppTheme.purple : AppTheme.textSecondary,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  _file != null ? p.basename(_file!.path) : 'File select karo',
                  style: GoogleFonts.rajdhani(
                    color: _file != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontSize: 14, fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_file == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Koi bhi file — info milegi',
                        style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                  ),
              ]),
            ),
          ),

          if (_info.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('File Details',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13,
                      fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppTheme.textSecondary,
                tooltip: 'Copy all info',
                onPressed: () {
                  final text = _info.entries.map((e) => '${e.key}: ${e.value}').join('\n');
                  Clipboard.setData(ClipboardData(text: text));
                  showSnack('Copy ho gaya!');
                },
              ),
            ]),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: _info.entries.map((entry) {
                  final isLast = entry.key == _info.keys.last;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: isLast ? null : Border(
                        bottom: BorderSide(color: AppTheme.borderColor),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(entry.key,
                              style: GoogleFonts.rajdhani(
                                  color: AppTheme.textSecondary, fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: entry.value));
                              showSnack('Copied: ${entry.key}');
                            },
                            child: Text(entry.value,
                                style: GoogleFonts.rajdhani(
                                    color: AppTheme.textPrimary, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
