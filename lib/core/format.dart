import 'package:intl/intl.dart';

/// Small formatting helpers shared across screens.
abstract final class Format {
  static final _date = DateFormat('d MMMM yyyy', 'fr_FR');

  /// `mm:ss` or `h:mm:ss`.
  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final mm = m.toString().padLeft(h > 0 ? 2 : 1, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  /// Short human duration, e.g. `32 min`.
  static String shortDuration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds} s';
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return m == 0 ? '$h h' : '$h h $m';
  }

  static String date(DateTime dt) => _date.format(dt);
}
