import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isdb_radio/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to light when nothing is stored', () async {
    final controller = ThemeController();
    await controller.load();
    expect(controller.mode, ThemeMode.light);
  });

  test('persists and reloads the chosen mode', () async {
    final a = ThemeController();
    await a.setMode(ThemeMode.dark);
    expect(a.mode, ThemeMode.dark);

    final b = ThemeController();
    await b.load();
    expect(b.mode, ThemeMode.dark);
  });

  test('notifies listeners on change', () async {
    final controller = ThemeController();
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.setMode(ThemeMode.dark);
    await controller.setMode(ThemeMode.dark); // no-op, same value

    expect(controller.mode, ThemeMode.dark);
    expect(notified, 1);
  });
}
