import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../player/widgets/mini_player.dart';
import 'episode_search_controller.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/episode_tile.dart';

class EpisodesSearchPage extends StatelessWidget {
  const EpisodesSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EpisodeSearchController()..init(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _apply(String term) {
    _field.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );
    context.read<EpisodeSearchController>().submit(term);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EpisodeSearchController>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _field,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: controller.onQueryChanged,
          onSubmitted: controller.submit,
          decoration: InputDecoration(
            hintText: 'Rechercher émission, sujet, mot-clé…',
            border: InputBorder.none,
            suffixIcon: controller.query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _field.clear();
                      controller.onQueryChanged('');
                    },
                  ),
          ),
        ),
      ),
      // The mini-player floats over the results (see AppShell) instead of
      // reserving its own strip, so it stays consistent everywhere it shows.
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                if (controller.categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 2),
                    child: CategoryFilterBar(
                      categories: controller.categories,
                      selected: controller.selectedCategory,
                      onSelected: controller.selectCategory,
                    ),
                  ),
                Expanded(child: _body(controller)),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: MiniPlayer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(EpisodeSearchController c) {
    if (!c.isSearching) {
      return _RecentSearches(
        recent: c.recent,
        onTap: _apply,
        onClear: c.clearRecent,
      );
    }
    if (c.isLoading) return const AppLoader();
    if (c.error != null) {
      return AppErrorView(message: c.error!, onRetry: () => c.submit(c.query));
    }
    if (c.results.isEmpty) {
      return const AppEmptyView(
        message: 'Aucun résultat.',
        icon: Icons.search_off_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: kFloatingBarClearance),
      itemCount: c.results.length,
      itemBuilder: (_, i) => EpisodeTile(episode: c.results[i], queue: c.results),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.recent,
    required this.onTap,
    required this.onClear,
  });

  final List<String> recent;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) {
      return const AppEmptyView(
        message: 'Tape un mot-clé pour rechercher une émission.',
        icon: Icons.search_rounded,
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: kFloatingBarClearance),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recherches récentes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: onClear, child: const Text('Tout effacer')),
            ],
          ),
        ),
        for (final term in recent)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(term),
            onTap: () => onTap(term),
          ),
      ],
    );
  }
}
