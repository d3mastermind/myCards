import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/templates/data/repositories/template_repository_impl.dart';
import '../../domain/entities/template_entity.dart';
import '../../domain/repositories/template_repository.dart';

class AllTemplatesPg extends StateNotifier<AsyncValue<List<TemplateEntity>>> {
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

  AllTemplatesPg({required TemplatesRepository repository})
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

final allTemplatesProvider =
    StateNotifierProvider<AllTemplatesPg, AsyncValue<List<TemplateEntity>>>(
        (ref) {
  return AllTemplatesPg(repository: ref.read(templateRepositoryProvider));
});
