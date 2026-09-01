import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/drawer_list_tile.dart';
import '../../player/widgets/mini_player.dart';
import 'info_controller.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    super.initState();
    // Always refresh on open so dashboard edits show up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InfoController>().load();
    });
  }

  Future<void> _open(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _has(String? v) => v != null && v.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InfoController>();
    final config = controller.config;
    final version = controller.version.isEmpty ? '—' : controller.version;

    return Scaffold(
      appBar: AppBar(title: const Text('Informations')),
      bottomNavigationBar: const MiniPlayer(),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (_has(config?.aboutText))
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  config!.aboutText!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const Divider(),
            DrawerListTile(
              icon: Icons.info_outline_rounded,
              title: 'Version',
              subtitle: controller.buildNumber.isEmpty
                  ? version
                  : '$version (${controller.buildNumber})',
              onTap: () {},
            ),
            if (_has(config?.websiteUrl))
              DrawerListTile(
                icon: Icons.language_rounded,
                title: 'Site web',
                subtitle: config!.websiteUrl,
                onTap: () => _open(config.websiteUrl),
              ),
            if (_has(config?.facebookUrl))
              DrawerListTile(
                icon: Icons.facebook_rounded,
                title: 'Facebook',
                onTap: () => _open(config!.facebookUrl),
              ),
            if (_has(config?.instagramUrl))
              DrawerListTile(
                icon: Icons.camera_alt_rounded,
                title: 'Instagram',
                onTap: () => _open(config!.instagramUrl),
              ),
            if (_has(config?.youtubeUrl))
              DrawerListTile(
                icon: Icons.smart_display_rounded,
                title: 'YouTube',
                onTap: () => _open(config!.youtubeUrl),
              ),
            if (_has(config?.tiktokUrl))
              DrawerListTile(
                icon: Icons.music_note_rounded,
                title: 'TikTok',
                onTap: () => _open(config!.tiktokUrl),
              ),
            if (_has(config?.contactPhone))
              DrawerListTile(
                icon: Icons.phone_rounded,
                title: 'Téléphone',
                subtitle: config!.contactPhone,
                onTap: () => _open('tel:${config.contactPhone}'),
              ),
            if (_has(config?.contactEmail))
              DrawerListTile(
                icon: Icons.mail_outline_rounded,
                title: 'Nous écrire',
                subtitle: config!.contactEmail,
                onTap: () => _open('mailto:${config.contactEmail}'),
              ),
            if (_has(config?.androidStoreUrl))
              DrawerListTile(
                icon: Icons.star_rounded,
                title: "Évaluer l'application",
                onTap: () => _open(config!.androidStoreUrl),
              ),
            if (_has(config?.privacyPolicyUrl))
              DrawerListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Politique de confidentialité',
                onTap: () => _open(config!.privacyPolicyUrl),
              ),
            DrawerListTile(
              icon: Icons.copyright_rounded,
              title: 'Radio ISDB',
              subtitle:
                  '© ${DateTime.now().year} Institut Supérieur Don Bosco',
              onTap: () {},
            ),
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
