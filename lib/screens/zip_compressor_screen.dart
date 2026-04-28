import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class ZipCompressorScreen extends BaseToolScreen {
  const ZipCompressorScreen({super.key}) : super(toolId: 'zip_compressor');
  @override
  State<ZipCompressorScreen> createState() => _ZipCompressorScreenState();
}

class _ZipCompressorScreenState extends BaseToolScreenState<ZipCompressorScreen> {
  final List<File> _files = [];
  int _level = 2; // 0=No, 1=Fastest, 2=Normal, 3=Ultra, 4=Max
  String? _savedPath;
  int _originalSize = 0;
  int _compressedSize = 0;
  final _nameCtrl = TextEditingController(text: 'compressed');

  final _levels = [
    _LevelInfo('No Compression', 'Files just pack honge, size same', 0, Icons.inventory_2_outlined),
    _LevelInfo('Fastest', 'Tez compression, thoda size kam', 2, Icons.speed_outlined),
    _LevelInfo('Normal', 'Balanced — recommended', 6, Icons.balance_outlined),
    _LevelInfo('Ultra', 'Zyada compression, thoda slow', 8, Icons.compress_outlined),
    _LevelInfo('Maximum', 'Best compression, slow process', 9, Icons.rocket_launch_outlined),
  ];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    if (!mounted) return;
    setState(() {
      _files.addAll(result.files.map((f) => File(f.path!)));
      _originalSize = _files.fold(0, (s, f) => s + f.lengthSync());
      _savedPath = null;
      _compressedSize = 0;
    });
  }

  Future<void> _compress() async {
    if (_files.isEmpty) { setError('Pehle files select karo!'); return; }
    setLoading(true);
    setError(null);
    try {
      final archive = Archive();
      for (final file in _files) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(p.basename(file.path), bytes.length, bytes));
      }

      final deflateLevel = _levels[_level].deflateLevel;
      final encoder = ZipEncoder();
      final zipBytes = encoder.encode(archive,
          level: deflateLevel == 0 ? Deflate.NO_COMPRESSION : deflateLevel)!;

      final dir = await getApplicationDocumentsDirectory();
      final safeName = _nameCtrl.text.trim().isEmpty ? 'compressed'
          : _nameCtrl.text.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final outFile = File('${dir.path}/$safeName.zip');
      await outFile.writeAsBytes(zipBytes);

      if (!mounted) return;
      setState(() {
        _savedPath = outFile.path;
        _compressedSize = outFile.lengthSync();
      });

      final saved = _originalSize - _compressedSize;
      final pct = _originalSize > 0 ? (saved / _originalSize * 100).round() : 0;
      showSnack('$pct% compression! ${_formatSize(saved)} bachaya ✅');
    } catch (e) {
      setError('Error: $e');
    } finally {
      if (mounted) setLoading(false);
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 0) return '0B';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pick files
          GestureDetector(
            onTap: _pickFiles,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _files.isNotEmpty ? AppTheme.purple : AppTheme.borderColor,
                  width: _files.isNotEmpty ? 1.5 : 1,
                ),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_circle_outline,
                    color: _files.isNotEmpty ? AppTheme.purple : AppTheme.textSecondary, size: 28),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    _files.isNotEmpty ? '${_files.length} files selected' : 'Files Select Karo',
                    style: GoogleFonts.rajdhani(
                        color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  if (_files.isNotEmpty)
                    Text('Total: ${_formatSize(_originalSize)}',
                        style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                ]),
                if (_files.isNotEmpty) ...[
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.red, size: 20),
                    onPressed: () => setState(() {
                      _files.clear(); _originalSize = 0;
                      _savedPath = null; _compressedSize = 0;
                    }),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Output name
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Output ZIP Name',
              prefixIcon: Icon(Icons.folder_zip_outlined),
              suffixText: '.zip',
            ),
          ),
          const SizedBox(height: 16),

          // Level selector
          Text('Compression Level',
              style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ..._levels.asMap().entries.map((entry) {
            final i = entry.key;
            final lvl = entry.value;
            final selected = _level == i;
            return GestureDetector(
              onTap: () => setState(() => _level = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.purple.withOpacity(0.15) : AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.purple : AppTheme.borderColor,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Icon(lvl.icon,
                      color: selected ? AppTheme.purple : AppTheme.textSecondary, size: 22),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lvl.name,
                          style: GoogleFonts.rajdhani(
                              color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(lvl.desc,
                          style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  )),
                  if (selected)
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
                      child: const Icon(Icons.check_circle, size: 20),
                    ),
                ]),
              ),
            );
          }),

          const SizedBox(height: 16),

          GradientButton(
            label: 'Compress Karo',
            icon: Icons.compress_outlined,
            onPressed: _compress,
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
                  Expanded(child: Text('Compression complete!',
                      style: GoogleFonts.rajdhani(
                          color: Colors.greenAccent, fontWeight: FontWeight.w600))),
                ]),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _statBox('Original', _formatSize(_originalSize), AppTheme.textSecondary),
                  const Icon(Icons.arrow_forward, color: AppTheme.textSecondary, size: 18),
                  _statBox('Compressed', _formatSize(_compressedSize), AppTheme.purple),
                  _statBox('Saved',
                    '${_originalSize > 0 ? ((_originalSize - _compressedSize) / _originalSize * 100).round() : 0}%',
                    Colors.greenAccent),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(_savedPath!)])),
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

  Widget _statBox(String label, String value, Color color) => Column(children: [
    Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
    Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
  ]);
}

class _LevelInfo {
  final String name, desc;
  final int deflateLevel;
  final IconData icon;
  const _LevelInfo(this.name, this.desc, this.deflateLevel, this.icon);
}
