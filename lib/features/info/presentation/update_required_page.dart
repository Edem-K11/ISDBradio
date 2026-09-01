import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Blocking screen shown when the installed version is below
/// `min_supported_version` from the API.
class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key, this.storeUrl});

  final String? storeUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.system_update_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Mise à jour requise',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Une nouvelle version de Radio ISDB est disponible. '
                'Merci de mettre à jour l’application pour continuer.',
                textAlign: TextAlign.center,
              ),
              if (storeUrl != null && storeUrl!.isNotEmpty) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    final uri = Uri.tryParse(storeUrl!);
                    if (uri != null) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Mettre à jour'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
