import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/templates/data/repositories/template_repository_impl.dart';
import '../../domain/entities/template_entity.dart';
import '../../domain/repositories/template_repository.dart';

class AllTemplates extends StateNotifier<AsyncValue<List<TemplateEntity>>> {
  final TemplatesRepository _repository;

  // Cache for templates
  List<TemplateEntity>? _cachedTemplates;
  DateTime? _lastFetched;
  final Duration _cacheExpiry = const Duration(minutes: 1);

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

  // Load all templates with caching
  Future<void> loadAllTemplates({bool forceRefresh = false}) async {
    // Use cache if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid) {
      state = AsyncValue.data(_cachedTemplates!);
      return;
    }
    log("[AllTemplates] Loading templates");
    state = const AsyncValue.loading();

    try {
      final templates = await _repository.getAllTemplates();
      _cachedTemplates = templates;
      _lastFetched = DateTime.now();
      state = AsyncValue.data(templates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error.toString(), stackTrace);
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
  }

  // Reset to initial state
  void reset() {
    state = const AsyncValue.data([]);
  }
}

final allTemplatesProvider =
    StateNotifierProvider<AllTemplates, AsyncValue<List<TemplateEntity>>>(
        (ref) {
  return AllTemplates(repository: ref.read(templateRepositoryProvider));
});
