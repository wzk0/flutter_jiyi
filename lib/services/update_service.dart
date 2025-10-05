import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateService {
  static final UpdateService instance = UpdateService._();
  UpdateService._();

  final String _apiUrl =
      'https://api.github.com/repos/wzk0/flutter_jiyi/releases/latest';

  Future<UpdateInfo?> checkForUpdates(String currentVersion) async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');
        final downloadUrl = data['html_url'];
        final releaseNotes = data['body'];

        if (_isVersionNewer(latestVersion, currentVersion)) {
          return UpdateInfo(
            version: latestVersion,
            downloadUrl: downloadUrl,
            releaseNotes: releaseNotes,
            isAvailable: true,
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('检查更新失败: $e');
    }
  }

  bool _isVersionNewer(String latest, String current) {
    try {
      final latestClean = latest.replaceAll('v', '').replaceAll('V', '');
      final currentClean = current.replaceAll('v', '').replaceAll('V', '');

      final latestParts = latestClean.split('.');
      final currentParts = currentClean.split('.');

      for (
        int i = 0;
        i < math.max(latestParts.length, currentParts.length);
        i++
      ) {
        final latestNum = i < latestParts.length
            ? int.tryParse(latestParts[i]) ?? 0
            : 0;
        final currentNum = i < currentParts.length
            ? int.tryParse(currentParts[i]) ?? 0
            : 0;

        if (latestNum > currentNum) return true;
        if (latestNum < currentNum) return false;
      }

      return false;
    } catch (e) {
      return true;
    }
  }
}

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final bool isAvailable;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.isAvailable,
  });
}
