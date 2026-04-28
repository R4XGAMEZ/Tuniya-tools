import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FileIoService {
  static const _baseUrl = 'https://file.io';

  static FileIoService? _instance;
  static FileIoService get instance => _instance ??= FileIoService._();
  FileIoService._();

  /// Upload a file and get a download link
  /// [expires] = '1h' | '6h' | '1d' | '3d' | '7d'
  Future<FileIoResult> uploadFile(File file, {String expires = '1d'}) async {
    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    request.fields['expires'] = expires;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedRes = await request.send();
    final res = await http.Response.fromStream(streamedRes);

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Upload failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Upload failed');
    }

    return FileIoResult(
      link: data['link'] ?? '',
      key: data['key'] ?? '',
      expires: data['expires'] ?? '',
      expiry: expires,
      fileName: file.path.split('/').last,
      fileSize: file.lengthSync(),
    );
  }

  /// Delete a file by key
  Future<bool> deleteFile(String key) async {
    final res = await http.delete(Uri.parse('$_baseUrl/$key'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] == true;
    }
    return false;
  }
}

class FileIoResult {
  final String link;
  final String key;
  final String expires;
  final String expiry;
  final String fileName;
  final int fileSize;

  FileIoResult({
    required this.link,
    required this.key,
    required this.expires,
    required this.expiry,
    required this.fileName,
    required this.fileSize,
  });

  String get fileSizeStr {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
