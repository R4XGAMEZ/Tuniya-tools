import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../base_tool_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AudioJoinerScreen extends BaseToolScreen {
  const AudioJoinerScreen({super.key}) : super(toolId: 'audio_joiner');
  @override
  State<AudioJoinerScreen> createState() => _AudioJoinerScreenState();
}

class _AudioJoinerScreenState extends BaseToolScreenState<AudioJoinerScreen> {
  String? errorMessage;
  final List<File> _files = [];
  String? _outputPath;
  String _format = 'MP3';

  Future<void> _addFiles() async {
    final r = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.audio);
    if (r == null) return;
    if (!mounted) return;
    setState(() { _files.addAll(r.files.map((f) => File(f.path!))); _outputPath = null; });
  }

  if (!mounted) return;
  void _removeFile(int i) => setState(() { _files.removeAt(i); _outputPath = null; });

  void _reorder(int oldIndex, int newIndex) {
    if (!mounted) return;
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final f = _files.removeAt(oldIndex);
      _files.insert(newIndex, f);
    });
  }

  Future<void> _join() async {
    if (_files.length < 2) { setError('Kam se kam 2 audio files chahiye!'); return; }
    setLoading(true); setError(null);
    try {
      final dir = await getTemporaryDirectory();
      final listFile = p.join(dir.path, 'concat_list.txt');
      final listContent = _files.map((f) => "file '${f.path}'").join('\n');
      await File(listFile).writeAsString(listContent);
      final ext = _format.toLowerCase();
      final out = p.join(dir.path, 'joined_${DateTime.now().millisecondsSinceEpoch}.$ext');
      final cmd = '-f concat -safe 0 -i "$listFile" -c:a ${_format == 'MP3' ? 'libmp3lame' : 'aac'} -b:a 192k "$out"';
      await FFmpegKit.execute(cmd);
      if (await File(out).exists()) {
        if (!mounted) return;
        setState(() => _outputPath = out);
      } else {
        setError('Join nahi hua. Files check karo.');
      }
    } catch (e) { setError('Error: $e'); }
    setLoading(false);
  }

  String _fmt(File f) {
    final kb = f.lengthSync() / 1024;
    return kb > 1024 ? '${(kb / 1024).toStringAsFixed(1)} MB' : '${kb.toStringAsFixed(0)} KB';
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Add files
            GestureDetector(
              onTap: _addFiles,
              child: Container(
                width: double.infinity, height: 90,
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor, width: 2, style: BorderStyle.solid)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_circle_outline, color: AppTheme.purple, size: 28),
                  const SizedBox(height: 6),
                  Text('Audio files add karo (MP3/AAC/WAV)', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            if (_files.isNotEmpty) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_files.length} Files (drag to reorder)', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                TextButton(onPressed: () => setState(() { _files.clear(); _outputPath = null; }), child: Text('Clear All', style: GoogleFonts.inter(color: AppTheme.red, fontSize: 12))),
              ]),
              ReorderableListView(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                onReorder: _reorder,
                children: _files.asMap().entries.map((e) => ListTile(
                  key: ValueKey(e.key),
                  leading: CircleAvatar(backgroundColor: AppTheme.purple.withValues(alpha: 0.2), child: Text('${e.key + 1}', style: GoogleFonts.inter(color: AppTheme.purple))),
                  title: Text(p.basename(e.value.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis),
                  subtitle: Text(_fmt(e.value), style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
                  trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeFile(e.key)),
                  tileColor: AppTheme.cardBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Format
            Row(children: [
              Text('Output Format: ', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              ...['MP3', 'AAC'].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _format = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(gradient: _format == f ? AppTheme.brandGradient : null, color: _format == f ? null : AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _format == f ? Colors.transparent : AppTheme.borderColor)),
                    child: Text(f, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                  ),
                ),
              )),
            ]),

            if (errorMessage != null) ...[const SizedBox(height: 12), Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red))],

            if (_outputPath != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade700)),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Audio join ho gaya! 🎵', style: GoogleFonts.inter(color: Colors.green))),
                  ElevatedButton(onPressed: () => Share.shareXFiles([XFile(_outputPath!)]), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple), child: const Icon(Icons.share)),
                ]),
              ),
            ],
          ]),
        ),
      ),
      if (isLoading) const LinearProgressIndicator(),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _join,
            icon: const Icon(Icons.merge),
            label: Text(isLoading ? 'Join ho raha hai...' : 'Audio Join Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: AppTheme.purple),
          ),
        ),
      ),
    ]);
  }
}
