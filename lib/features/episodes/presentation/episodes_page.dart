import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_state_views.dart';
import 'episodes_controller.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/episode_tile.dart';

class EpisodesPage extends StatelessWidget {
  const EpisodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EpisodesController()..init(),
      child: const _EpisodesView(),
    );
  }
}

class _EpisodesView extends StatefulWidget {
  const _EpisodesView();

  @override
  State<_EpisodesView> createState() => _EpisodesViewState();
}

class _EpisodesViewState extends State<_EpisodesView> {
  final _scrollController = ScrollController();
  bool _headerElevated = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      context.read<EpisodesController>().loadMore();
    }
    final elevated = pos.pixels > 4;
    if (elevated != _headerElevated) {
      setState(() => _headerElevated = elevated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EpisodesController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              titleSpacing: 16,
              centerTitle: false,
              toolbarHeight: 64,
              // Subtle drop shadow once the list scrolls under the header.
              elevation: 4,
              scrolledUnderElevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              surfaceTintColor: Colors.transparent,
              forceElevated: _headerElevated,
              title: Text(
                'Émissions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Rechercher',
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => context.push('/episodes/search'),
                ),
                const SizedBox(width: 4),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 24, 4),
                child: Text(
                  'Réécouter toutes vos émissions préférées en replay/podcasts '
                  'sur Radio ISDB',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: CategoryFilterBar(
                  categories: controller.categories,
                  selected: controller.selectedCategory,
                  onSelected: controller.selectCategory,
                ),
              ),
            ),
            ..._buildBody(controller),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(EpisodesController c) {
    if (c.isLoading) {
      return const [SliverFillRemaining(child: AppLoader())];
    }
    if (c.error != null) {
      return [
        SliverFillRemaining(
          child: AppErrorView(message: c.error!, onRetry: c.load),
        ),
      ];
    }
    if (c.isEmpty) {
      return const [
        SliverFillRemaining(
          child: AppEmptyView(
            message: 'Aucune émission pour le moment.',
            icon: Icons.podcasts_rounded,
          ),
        ),
      ];
    }
    return [
      SliverList.builder(
        itemCount: c.episodes.length + (c.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= c.episodes.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return EpisodeTile(episode: c.episodes[index]);
        },
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];
  }
}
