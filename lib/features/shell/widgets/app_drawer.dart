import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/drawer_list_tile.dart';

/// Navigation drawer shared by the shell.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const logo = AssetImage('assets/images/logo_isdb.png');

    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Opacity(
                  opacity: 0.25,
                  child: Image(image: logo, fit: BoxFit.cover),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.green,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Image(image: logo, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Radio ISDB',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerListTile(
                  icon: Icons.sensors_rounded,
                  title: 'Direct',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/live');
                  },
                ),
                DrawerListTile(
                  icon: Icons.podcasts_rounded,
                  title: 'Émissions',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/episodes');
                  },
                ),
                Divider(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                DrawerListTile(
                  icon: Icons.palette_outlined,
                  title: 'Apparence',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings/appearance');
                  },
                ),
                DrawerListTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Informations',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/info');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
