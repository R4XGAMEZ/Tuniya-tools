import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum DownloadStatus { queued, downloading, done, failed }

class DownloadItem {
  final String id;
  final String url;
  final String fileName;
  final String platform;
  double progress;
  DownloadStatus status;
  String? savedPath;
  String? error;
  DateTime startedAt;

  DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.platform,
    this.progress = 0,
    this.status = DownloadStatus.queued,
    this.savedPath,
    this.error,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();
}

class DownloadService {
  static DownloadService? _instance;
  static DownloadService get instance => _instance ??= DownloadService._();
  DownloadService._();

  final _dio = Dio();
  final List<DownloadItem> downloads = [];
  final List<void Function()> _listeners = [];

  void addListener(void Function() fn) => _listeners.add(fn);
  void removeListener(void Function() fn) => _listeners.remove(fn);
  void _notify() { for (final l in _listeners) l(); }

  Future<String> get _downloadDir async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir?.path ?? '/storage/emulated/0'}/TUNIYA TOOLS';
    await Directory(path).create(recursive: true);
    return path;
  }

  // ─── Direct URL download (for non-yt-dlp cases) ──────────────────────────
  Future<void> downloadDirect(String url, String fileName, String platform) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = DownloadItem(id: id, url: url, fileName: fileName, platform: platform);
    downloads.insert(0, item);
    _notify();

    try {
      final dir = await _downloadDir;
      final savePath = '$dir/$fileName';
      await _dio.download(
        url, savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            item.progress = received / total;
            _notify();
          }
        },
      );
      item.status = DownloadStatus.done;
      item.savedPath = savePath;
      await _saveHistory();
    } catch (e) {
      item.status = DownloadStatus.failed;
      item.error = e.toString();
    }
    _notify();
  }

  // ─── yt-dlp based download ────────────────────────────────────────────────
  /// Returns ytdlp command string (execute via process or shell)
  String buildYtdlpCommand({
    required String url,
    required String outputDir,
    String quality = 'best',
    bool audioOnly = false,
    String format = 'mp4',
  }) {
    if (audioOnly) {
      return 'yt-dlp -x --audio-format mp3 --audio-quality 0 '
          '-o "$outputDir/%(title)s.%(ext)s" "$url"';
    }
    final qualityFilter = _qualityToFormat(quality);
    return 'yt-dlp -f "$qualityFilter" --merge-output-format $format '
        '-o "$outputDir/%(title)s.%(ext)s" "$url"';
  }

  String _qualityToFormat(String quality) {
    switch (quality) {
      case '4K': return 'bestvideo[height<=2160]+bestaudio/best';
      case '1080p': return 'bestvideo[height<=1080]+bestaudio/best';
      case '720p': return 'bestvideo[height<=720]+bestaudio/best';
      case '480p': return 'bestvideo[height<=480]+bestaudio/best';
      case '360p': return 'bestvideo[height<=360]+bestaudio/best';
      case '240p': return 'bestvideo[height<=240]+bestaudio/best';
      case '144p': return 'bestvideo[height<=144]+bestaudio/best';
      default: return 'bestvideo+bestaudio/best';
    }
  }

  /// Run yt-dlp as a subprocess (requires yt-dlp installed on device)
  Future<void> runYtdlp(String url, {
    bool audioOnly = false,
    String quality = 'best',
    String platform = 'YouTube',
    void Function(String line)? onLog,
  }) async {
    final dir = await _downloadDir;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = DownloadItem(
      id: id, url: url,
      fileName: audioOnly ? 'audio.mp3' : 'video.mp4',
      platform: platform,
    );
    downloads.insert(0, item);
    item.status = DownloadStatus.downloading;
    _notify();

    try {
      final cmd = buildYtdlpCommand(
          url: url, outputDir: dir, quality: quality, audioOnly: audioOnly);
      final parts = cmd.split(' ');
      final process = await Process.start(parts.first, parts.sublist(1));

      process.stdout.transform(const SystemEncoding().decoder).listen((line) {
        onLog?.call(line);
        // Parse progress from yt-dlp output
        if (line.contains('%')) {
          final match = RegExp(r'(\d+\.?\d*)%').firstMatch(line);
          if (match != null) {
            item.progress = double.tryParse(match.group(1) ?? '0')! / 100;
            _notify();
          }
        }
      });
      process.stderr.transform(const SystemEncoding().decoder).listen((line) {
        onLog?.call('[err] $line');
      });

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        item.status = DownloadStatus.done;
        item.savedPath = dir;
      } else {
        item.status = DownloadStatus.failed;
        item.error = 'yt-dlp exited with code $exitCode';
      }
    } catch (e) {
      item.status = DownloadStatus.failed;
      item.error = e.toString();
    }
    _notify();
    await _saveHistory();
  }

  // ─── WhatsApp Status ──────────────────────────────────────────────────────
  Future<List<FileSystemEntity>> getWhatsAppStatuses() async {
    final paths = [
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
      '/storage/emulated/0/WhatsApp/Media/.Statuses',
    ];
    for (final path in paths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        return dir.listSync().where((f) =>
            f.path.endsWith('.mp4') ||
            f.path.endsWith('.jpg') ||
            f.path.endsWith('.jpeg') ||
            f.path.endsWith('.png')).toList();
      }
    }
    return [];
  }

  Future<void> saveWhatsAppStatus(FileSystemEntity file) async {
    final dir = await _downloadDir;
    final name = file.path.split('/').last;
    await File(file.path).copy('$dir/$name');
  }

  // ─── History persistence ──────────────────────────────────────────────────
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = downloads.take(50).map((d) => jsonEncode({
      'id': d.id, 'url': d.url, 'fileName': d.fileName,
      'platform': d.platform, 'status': d.status.name,
      'savedPath': d.savedPath, 'error': d.error,
    })).toList();
    await prefs.setStringList('download_history', list);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('download_history') ?? [];
    downloads.clear();
    for (final s in list) {
      try {
        final m = jsonDecode(s) as Map;
        downloads.add(DownloadItem(
          id: m['id'], url: m['url'], fileName: m['fileName'],
          platform: m['platform'],
          status: DownloadStatus.values.byName(m['status'] ?? 'done'),
          savedPath: m['savedPath'], error: m['error'],
        ));
      } catch (_) {}
    }
    _notify();
  }

  void clearHistory() {
    downloads.removeWhere((d) => d.status == DownloadStatus.done);
    _notify();
  }
}
