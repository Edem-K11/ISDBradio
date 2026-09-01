import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Copies the bundled ISDB logo to a real file once, so the media notification
/// always has artwork (and Android can tint the notification from it) even when
/// an episode or the stream has no cover.
class DefaultArt {
  DefaultArt._();

  static Uri? uri;

  static Future<void> prepare() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/notification_art.png');
      if (!file.existsSync()) {
        final bytes = await rootBundle.load('assets/images/logo_isdb.png');
        await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      }
      uri = Uri.file(file.path);
    } catch (_) {
      uri = null;
    }
  }
}
