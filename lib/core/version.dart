/// Minimal semantic-version comparison (`x.y.z`, extra parts ignored).
abstract final class Version {
  /// Returns true when [current] is older than [minimum].
  static bool isOlder(String current, String minimum) {
    final a = _parts(current);
    final b = _parts(minimum);
    for (var i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i] < b[i];
    }
    return false;
  }

  static List<int> _parts(String v) {
    final nums = v
        .split('+')
        .first
        .split('.')
        .map((s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    while (nums.length < 3) {
      nums.add(0);
    }
    return nums;
  }
}
