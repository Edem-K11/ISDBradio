import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/episode.dart';
import '../data/episode_repository.dart';
import '../data/program_category.dart';

/// Drives the paginated "Émissions" list and its category filter.
class EpisodesController extends ChangeNotifier {
  EpisodesController({EpisodeRepository? repository})
    : _repo = repository ?? EpisodeRepository();

  final EpisodeRepository _repo;
  static const _perPage = 15;

  final List<Episode> _episodes = [];
  List<ProgramCategory> _categories = [];
  String? _selectedCategory;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;

  List<Episode> get episodes => List.unmodifiable(_episodes);
  List<ProgramCategory> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get isEmpty => !_loading && _error == null && _episodes.isEmpty;

  Future<void> init() async {
    if (_episodes.isNotEmpty || _loading) return;
    await Future.wait([_loadCategories(), load()]);
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _repo.fetchCategories();
      notifyListeners();
    } on ApiException {
      // The filter row just stays empty.
    }
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    _page = 1;
    notifyListeners();
    try {
      final result = await _repo.fetchEpisodes(
        page: 1,
        perPage: _perPage,
        categorySlug: _selectedCategory,
      );
      _episodes
        ..clear()
        ..addAll(result.items);
      _hasMore = result.hasMore;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() {
    _episodes.clear();
    return load();
  }

  Future<void> loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final result = await _repo.fetchEpisodes(
        page: _page + 1,
        perPage: _perPage,
        categorySlug: _selectedCategory,
      );
      _episodes.addAll(result.items);
      _page = result.currentPage;
      _hasMore = result.hasMore;
    } on ApiException {
      // Keep what we have; the user can scroll again to retry.
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String? slug) {
    if (_selectedCategory == slug) return Future.value();
    _selectedCategory = slug;
    _episodes.clear();
    return load();
  }
}
