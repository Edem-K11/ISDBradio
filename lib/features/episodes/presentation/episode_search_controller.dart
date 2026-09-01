import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_exception.dart';
import '../data/episode.dart';
import '../data/episode_repository.dart';
import '../data/program_category.dart';

/// Debounced server-side episode search with a category filter and a persisted
/// recent-queries list.
class EpisodeSearchController extends ChangeNotifier {
  EpisodeSearchController({EpisodeRepository? repository})
    : _repo = repository ?? EpisodeRepository();

  final EpisodeRepository _repo;
  static const _recentKey = 'recent_searches_v1';
  static const _maxRecent = 8;

  Timer? _debounce;
  String _query = '';
  String? _category;
  List<ProgramCategory> _categories = [];
  List<Episode> _results = [];
  List<String> _recent = [];
  bool _loading = false;
  String? _error;

  String get query => _query;
  String? get selectedCategory => _category;
  List<ProgramCategory> get categories => _categories;
  List<Episode> get results => _results;
  List<String> get recent => _recent;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get hasQuery => _query.trim().length >= 2;

  /// Show results whenever there is a query OR a category picked.
  bool get isSearching => hasQuery || _category != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _recent = prefs.getStringList(_recentKey) ?? [];
    notifyListeners();
    try {
      _categories = await _repo.fetchCategories();
      notifyListeners();
    } on ApiException {
      // Filter row just stays empty.
    }
  }

  void onQueryChanged(String value) {
    _query = value;
    notifyListeners();
    _debounce?.cancel();
    if (!isSearching) {
      _results = [];
      _error = null;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), _run);
  }

  Future<void> submit(String value) async {
    _debounce?.cancel();
    _query = value;
    await _run();
  }

  Future<void> selectCategory(String? slug) async {
    if (_category == slug) return;
    _category = slug;
    _debounce?.cancel();
    if (!isSearching) {
      _results = [];
      _error = null;
      notifyListeners();
      return;
    }
    await _run();
  }

  Future<void> _run() async {
    if (!isSearching) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _repo.fetchEpisodes(
        search: hasQuery ? _query : null,
        categorySlug: _category,
        perPage: 30,
      );
      _results = page.items;
      if (hasQuery) await _remember(_query.trim());
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _remember(String term) async {
    _recent
      ..removeWhere((e) => e.toLowerCase() == term.toLowerCase())
      ..insert(0, term);
    if (_recent.length > _maxRecent) _recent = _recent.sublist(0, _maxRecent);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recent);
  }

  Future<void> clearRecent() async {
    _recent = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
