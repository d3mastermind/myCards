import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/templates/data/repositories/template_repository_impl.dart';
import '../../domain/entities/template_entity.dart';
import '../../domain/repositories/template_repository.dart';

// Paginated provider for UI (used by HomeScreen)
class AllTemplates extends StateNotifier<AsyncValue<List<TemplateEntity>>> {
  final TemplatesRepository _repository;

  // Cache for templates
  List<TemplateEntity>? _cachedTemplates;
  DateTime? _lastFetched;
  final Duration _cacheExpiry = const Duration(minutes: 1);

  // Pagination state
  String? _lastDocumentId;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  static const int pageSize = 20;

  AllTemplates({required TemplatesRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading()) {
    loadAllTemplates();
  }

  // Check if cache is valid
  bool get _isCacheValid {
    return _cachedTemplates != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < _cacheExpiry;
  }

  // Load all templates with caching (first page)
  Future<void> loadAllTemplates({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) {
      state = AsyncValue.data(_cachedTemplates!);
      return;
    }
    state = const AsyncValue.loading();
    _lastDocumentId = null;
    _hasMore = true;
    try {
      final templates = await _repository.getAllTemplates(limit: pageSize);
      _cachedTemplates = templates;
      _lastFetched = DateTime.now();
      if (templates.length < pageSize) _hasMore = false;
      if (templates.isNotEmpty) {
        _lastDocumentId = templates.last.templateId;
      }
      state = AsyncValue.data(templates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error.toString(), stackTrace);
    }
  }

  // Load more templates (pagination)
  Future<void> loadMoreTemplates() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
      final moreTemplates = await _repository.getAllTemplates(
        limit: pageSize,
        startAfterId: _lastDocumentId,
      );
      if (moreTemplates.isEmpty || moreTemplates.length < pageSize) {
        _hasMore = false;
      }
      if (moreTemplates.isNotEmpty) {
        _lastDocumentId = moreTemplates.last.templateId;
      }
      final current = _cachedTemplates ?? [];
      _cachedTemplates = [...current, ...moreTemplates];
      state = AsyncValue.data(_cachedTemplates!);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error.toString(), stackTrace);
    } finally {
      _isLoadingMore = false;
    }
  }

  // Clear cache and reload
  Future<void> refresh() async {
    clearCache();
    await loadAllTemplates(forceRefresh: true);
  }

  // Clear cache
  void clearCache() {
    _cachedTemplates = null;
    _lastFetched = null;
    _lastDocumentId = null;
    _hasMore = true;
  }

  // Reset to initial state
  void reset() {
    state = const AsyncValue.data([]);
    _lastDocumentId = null;
    _hasMore = true;
  }

  // Expose hasMore and isLoadingMore for UI
  bool getHasMore() => _hasMore;
  bool getIsLoadingMore() => _isLoadingMore;
}

// Background provider that loads all templates without pagination (used by CategoriesScreen and others)
class AllTemplatesBackground
    extends StateNotifier<AsyncValue<List<TemplateEntity>>> {
  final TemplatesRepository _repository;

  // Cache for all templates
  List<TemplateEntity>? _cachedAllTemplates;
  DateTime? _lastFetched;
  final Duration _cacheExpiry =
      const Duration(minutes: 5); // Longer cache for background loading

  AllTemplatesBackground({required TemplatesRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading()) {
    loadAllTemplatesBackground();
  }

  // Check if cache is valid
  bool get _isCacheValid {
    return _cachedAllTemplates != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < _cacheExpiry;
  }

  // Load all templates in background (no pagination)
  Future<void> loadAllTemplatesBackground({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) {
      state = AsyncValue.data(_cachedAllTemplates!);
      return;
    }

    state = const AsyncValue.loading();
    try {
      log("[AllTemplatesBackground] Loading all templates in background");
      // Load all templates without pagination (pass null for startAfterId to get all)
      final allTemplates =
          await _repository.getAllTemplates(limit: 1000, startAfterId: null);
      _cachedAllTemplates = allTemplates;
      _lastFetched = DateTime.now();
      log("[AllTemplatesBackground] Loaded ${allTemplates.length} templates");
      state = AsyncValue.data(allTemplates);
    } catch (error, stackTrace) {
      log("[AllTemplatesBackground] Error loading all templates: $error");
      state = AsyncValue.error(error.toString(), stackTrace);
    }
  }

  // Clear cache and reload
  Future<void> refresh() async {
    clearCache();
    await loadAllTemplatesBackground(forceRefresh: true);
  }

  // Clear cache
  void clearCache() {
    _cachedAllTemplates = null;
    _lastFetched = null;
  }

  // Reset to initial state
  void reset() {
    state = const AsyncValue.data([]);
  }
}

// Paginated provider for UI (HomeScreen)
final allTemplatesProvider =
    StateNotifierProvider<AllTemplates, AsyncValue<List<TemplateEntity>>>(
        (ref) {
  return AllTemplates(repository: ref.read(templateRepositoryProvider));
});

// Background provider for loading all templates (CategoriesScreen and others)
final allTemplatesBackgroundProvider = StateNotifierProvider<
    AllTemplatesBackground, AsyncValue<List<TemplateEntity>>>((ref) {
  return AllTemplatesBackground(
      repository: ref.read(templateRepositoryProvider));
});
