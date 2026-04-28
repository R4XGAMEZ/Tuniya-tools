import 'package:share_plus/share_plus.dart';
import 'package:share_plus/share_plus.dart';
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

class VideoCompressorScreen extends BaseToolScreen {
  const VideoCompressorScreen({super.key}) : super(toolId: 'video_compressor');
  @override
  State<VideoCompressorScreen> createState() => _VideoCompressorScreenState();
}

class _VideoCompressorScreenState extends BaseToolScreenState<VideoCompressorScreen> {
  File? _videoFile;
  String _quality = '480p';
  String? _outputPath;
  int _originalSize = 0;
  int _compressedSize = 0;
  double _progress = 0;

  final _qualities = ['144p', '240p', '360p', '480p', '720p', '1080p'];

  String get _crf {
    switch (_quality) {
      case '144p': return '35';
      case '240p': return '32';
      case '360p': return '28';
      case '480p': return '26';
      case '720p': return '23';
      case '1080p': return '20';
      default: return '26';
    }
  }

  String get _scale {
    switch (_quality) {
      case '144p': return 'scale=256:144';
      case '240p': return 'scale=426:240';
      case '360p': return 'scale=640:360';
      case '480p': return 'scale=854:480';
      case '720p': return 'scale=1280:720';
      case '1080p': return 'scale=1920:1080';
      default: return 'scale=854:480';
    }
  }

  Future<void> _pickVideo() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.video);
    if (r == null) return;
    if (!mounted) return;
    setState(() {
      _videoFile = File(r.files.single.path!);
      _originalSize = _videoFile!.lengthSync();
      _outputPath = null;
      _compressedSize = 0;
      _progress = 0;
    });
  }

  Future<void> _compress() async {
    if (_videoFile == null) { setError('Pehle video select karo!'); return; }
    setLoading(true); setError(null);
    setState(() { _progress = 0; });
    try {
      final dir = await getTemporaryDirectory();
      final out = p.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.mp4');
      final cmd = '-i "${_videoFile!.path}" -vf "$_scale,setsar=1" -c:v libx264 -crf $_crf -preset fast -c:a aac -b:a 128k "$out"';
      await // ffmpeg removed
      final outFile = File(out);
      if (await outFile.exists()) {
        if (!mounted) return;
        setState(() {
          _outputPath = out;
          _compressedSize = outFile.lengthSync();
          _progress = 1;
        });
      } else {
        setError('Compression fail ho gayi. Video check karo.');
      }
    } catch (e) {
      setError('Error: $e');
    }
    setLoading(false);
  }

  String _fmtSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  int get _saved => _originalSize > 0 && _compressedSize > 0
      ? ((_originalSize - _compressedSize) * 100 ~/ _originalSize)
      : 0;

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Pick video
        GestureDetector(
          onTap: _pickVideo,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _videoFile != null ? AppTheme.purple : AppTheme.borderColor, width: 2),
            ),
            child: _videoFile == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.video_file_outlined, color: AppTheme.purple, size: 36),
                    const SizedBox(height: 8),
                    Text('Video select karo', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                  ])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
                    const SizedBox(height: 6),
                    Text(p.basename(_videoFile!.path), style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis),
                    Text(_fmtSize(_originalSize), style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                  ]),
          ),
        ),
        const SizedBox(height: 20),

        // Quality selector
        Text('Output Quality', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _qualities.map((q) {
            final sel = q == _quality;
            return GestureDetector(
              onTap: () => setState(() => _quality = q),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: sel ? AppTheme.brandGradient : null,
                  color: sel ? null : AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? Colors.transparent : AppTheme.borderColor),
                ),
                child: Text(q, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        if (isLoading) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text('Compress ho raha hai...', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
        ],

        if (errorMessage != null) ...[
          Text(errorMessage!, style: GoogleFonts.inter(color: Colors.red)),
          const SizedBox(height: 12),
        ],

        // Result
        if (_outputPath != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade700)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _stat('Original', _fmtSize(_originalSize)),
                Icon(Icons.arrow_forward, color: AppTheme.textSecondary),
                _stat('Compressed', _fmtSize(_compressedSize)),
                _stat('Saved', '$_saved%', color: Colors.green),
              ]),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Share.shareXFiles([XFile(_outputPath!)]),
                  icon: const Icon(Icons.share),
                  label: Text('Share / Save', style: GoogleFonts.inter()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        if (!isLoading)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _compress,
              icon: const Icon(Icons.compress),
              label: Text('Compress Karo', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: AppTheme.purple,
              ),
            ),
          ),
      ]),
    );
  }

  Widget _stat(String label, String value, {Color? color}) => Column(children: [
    Text(value, style: GoogleFonts.inter(color: color ?? AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
    Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
  ]);
}
