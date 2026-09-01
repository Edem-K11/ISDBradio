import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_controller.dart';
import '../../player/widgets/mini_player.dart';

/// Lets the user pick between light, dark and the system theme.
class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Apparence')),
      bottomNavigationBar: const MiniPlayer(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              "Thème de l'application",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          RadioGroup<ThemeMode>(
            groupValue: controller.mode,
            onChanged: (mode) {
              if (mode != null) controller.setMode(mode);
            },
            child: const Column(
              children: [
                _ThemeOption(
                  mode: ThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  title: 'Clair',
                ),
                _ThemeOption(
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  title: 'Sombre',
                ),
                _ThemeOption(
                  mode: ThemeMode.system,
                  icon: Icons.brightness_auto_rounded,
                  title: 'Thème du système',
                  subtitle: 'Suit le réglage de ton téléphone',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final ThemeMode mode;
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: mode,
      secondary: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
