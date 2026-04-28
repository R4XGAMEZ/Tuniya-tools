import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'base_tool_screen.dart';

class BatchRenameScreen extends BaseToolScreen {
  const BatchRenameScreen({super.key}) : super(toolId: 'file_rename_batch');
  @override
  State<BatchRenameScreen> createState() => _BatchRenameScreenState();
}

class _BatchRenameScreenState extends BaseToolScreenState<BatchRenameScreen> {
  List<_FileEntry> _files = [];
  String _mode = 'prefix'; // prefix, suffix, replace, sequence
  final _prefixCtrl = TextEditingController(text: 'tuniya_');
  final _suffixCtrl = TextEditingController(text: '_edited');
  final _findCtrl = TextEditingController();
  final _replaceCtrl = TextEditingController();
  final _seqNameCtrl = TextEditingController(text: 'file');
  int _seqStart = 1;
  int _renamed = 0;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    if (!mounted) return;
    setState(() {
      _files = result.files.map((f) => _FileEntry(
        original: f.path!,
        originalName: f.name,
        preview: f.name,
        done: false,
      )).toList();
      _renamed = 0;
      _updatePreviews();
    });
  }

  void _updatePreviews() {
    for (int i = 0; i < _files.length; i++) {
      final entry = _files[i];
      final ext = p.extension(entry.originalName);
      final nameNoExt = p.basenameWithoutExtension(entry.originalName);

      String newName;
      switch (_mode) {
        case 'prefix':
          newName = '${_prefixCtrl.text}$nameNoExt$ext';
          break;
        case 'suffix':
          newName = '$nameNoExt${_suffixCtrl.text}$ext';
          break;
        case 'replace':
          if (_findCtrl.text.isEmpty) {
            newName = entry.originalName;
          } else {
            newName = entry.originalName.replaceAll(_findCtrl.text, _replaceCtrl.text);
          }
          break;
        case 'sequence':
          final num = (_seqStart + i).toString().padLeft(3, '0');
          newName = '${_seqNameCtrl.text}_$num$ext';
          break;
        default:
          newName = entry.originalName;
      }
      _files[i] = entry.copyWith(preview: newName);
    }
    setState(() {});
  }

  Future<void> _doRename() async {
    if (_files.isEmpty) { setError('Pehle files select karo!'); return; }
    setLoading(true);
    setError(null);
    int count = 0;
    for (int i = 0; i < _files.length; i++) {
      try {
        final entry = _files[i];
        final dir = p.dirname(entry.original);
        final newPath = p.join(dir, entry.preview);
        await File(entry.original).rename(newPath);
        if (!mounted) return;
        setState(() {
          _files[i] = entry.copyWith(done: true);
          count++;
          _renamed = count;
        });
      } catch (_) {}
    }
    setLoading(false);
    showSnack('$count files rename ho gayi! ✅');
  }


  @override
  void dispose() {
    _findCtrl.dispose();
    _replaceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pick files
          OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.add_outlined),
            label: Text('Files Select Karo', style: GoogleFonts.rajdhani(fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.purple,
              side: BorderSide(color: AppTheme.purple.withValues(alpha: 0.5)),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),

          // Mode selector
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rename Mode',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                _modeChip('prefix', 'Add Prefix'),
                _modeChip('suffix', 'Add Suffix'),
                _modeChip('replace', 'Find & Replace'),
                _modeChip('sequence', 'Sequence'),
              ]),
              const SizedBox(height: 12),
              _modeOptions(),
            ]),
          ),
          const SizedBox(height: 16),

          if (_files.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_files.length} files',
                  style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
              TextButton(
                onPressed: () => setState(() { _files.clear(); _renamed = 0; }),
                child: Text('Clear', style: GoogleFonts.rajdhani(color: AppTheme.red)),
              ),
            ]),
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _files.length,
                itemBuilder: (_, i) {
                  final f = _files[i];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      f.done ? Icons.check_circle : Icons.insert_drive_file_outlined,
                      color: f.done ? Colors.greenAccent : AppTheme.textSecondary,
                      size: 18,
                    ),
                    title: Text(f.preview,
                        style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(f.originalName,
                        style: GoogleFonts.rajdhani(
                            color: AppTheme.textSecondary, fontSize: 10,
                            decoration: TextDecoration.lineThrough),
                        overflow: TextOverflow.ellipsis),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          GradientButton(
            label: _renamed > 0 ? '$_renamed / ${_files.length} Renamed' : 'Rename Karo',
            icon: Icons.drive_file_rename_outline,
            onPressed: _doRename,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _modeChip(String value, String label) {
    final selected = _mode == value;
    return GestureDetector(
      onTap: () { setState(() => _mode = value); _updatePreviews(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.brandGradient : null,
          color: selected ? null : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : AppTheme.borderColor),
        ),
        child: Text(label,
            style: GoogleFonts.rajdhani(
                color: selected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _modeOptions() {
    switch (_mode) {
      case 'prefix':
        return TextField(
          controller: _prefixCtrl,
          onChanged: (_) => _updatePreviews(),
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Prefix', prefixIcon: Icon(Icons.text_fields)),
        );
      case 'suffix':
        return TextField(
          controller: _suffixCtrl,
          onChanged: (_) => _updatePreviews(),
          style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Suffix', prefixIcon: Icon(Icons.text_fields)),
        );
      case 'replace':
        return Column(children: [
          TextField(
            controller: _findCtrl,
            onChanged: (_) => _updatePreviews(),
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Find', prefixIcon: Icon(Icons.search)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _replaceCtrl,
            onChanged: (_) => _updatePreviews(),
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Replace with', prefixIcon: Icon(Icons.find_replace)),
          ),
        ]);
      case 'sequence':
        return Column(children: [
          TextField(
            controller: _seqNameCtrl,
            onChanged: (_) => _updatePreviews(),
            style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Base Name', hintText: 'e.g. photo'),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Text('Start #: $_seqStart',
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
            Expanded(child: Slider(
              value: _seqStart.toDouble(), min: 0, max: 100, divisions: 100,
              activeColor: AppTheme.purple,
              onChanged: (v) { setState(() => _seqStart = v.round()); _updatePreviews(); },
            )),
          ]),
        ]);
      default: return const SizedBox();
    }
  }
}

class _FileEntry {
  final String original, originalName, preview;
  final bool done;
  _FileEntry({required this.original, required this.originalName,
    required this.preview, required this.done});
  _FileEntry copyWith({String? preview, bool? done}) => _FileEntry(
    original: original, originalName: originalName,
    preview: preview ?? this.preview, done: done ?? this.done,
  );
}
