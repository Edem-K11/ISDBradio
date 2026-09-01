import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/version.dart';
import '../data/app_config.dart';
import '../data/app_config_repository.dart';

/// Loads the remote app configuration and the local package version.
/// Shared by the Info screen and the force-update gate.
class InfoController extends ChangeNotifier {
  InfoController({AppConfigRepository? repository})
    : _repo = repository ?? AppConfigRepository();

  final AppConfigRepository _repo;

  AppConfig? _config;
  String _version = '';
  String _buildNumber = '';
  bool _loading = false;
  String? _error;

  AppConfig? get config => _config;
  String get version => _version;
  String get buildNumber => _buildNumber;
  bool get isLoading => _loading;
  String? get error => _error;

  bool get needsUpdate =>
      _config != null &&
      _version.isNotEmpty &&
      Version.isOlder(_version, _config!.minSupportedVersion);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final info = await PackageInfo.fromPlatform();
      _version = info.version;
      _buildNumber = info.buildNumber;
    } catch (_) {
      // Leave version empty; the gate simply won't trigger.
    }

    try {
      _config = await _repo.get();
    } on ApiException catch (e) {
      _error = e.message;
    }

    _loading = false;
    notifyListeners();
  }
}
