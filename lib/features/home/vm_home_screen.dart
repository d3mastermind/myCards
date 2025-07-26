import 'package:mycards/features/templates/domain/entities/template_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/templates/presentation/providers/all_templates.dart';
import 'package:mycards/features/home/services/asset_upload_service.dart';

class HomeScreenState {
  final AsyncValue<List<TemplateEntity>> templates;
  final List<TemplateEntity> filteredTemplates;
  final String searchQuery;
  final String selectedCategory;
  final bool isUploading;
  final String uploadProgress;
  final AsyncValue<Map<String, dynamic>?> uploadResult;
  final bool hasMore;
  final bool isLoadingMore;

  const HomeScreenState({
    required this.templates,
    required this.filteredTemplates,
    required this.searchQuery,
    required this.selectedCategory,
    this.isUploading = false,
    this.uploadProgress = '',
    this.uploadResult = const AsyncValue.data(null),
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  HomeScreenState copyWith({
    AsyncValue<List<TemplateEntity>>? templates,
    List<TemplateEntity>? filteredTemplates,
    String? searchQuery,
    String? selectedCategory,
    bool? isUploading,
    String? uploadProgress,
    AsyncValue<Map<String, dynamic>?>? uploadResult,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeScreenState(
      templates: templates ?? this.templates,
      filteredTemplates: filteredTemplates ?? this.filteredTemplates,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadResult: uploadResult ?? this.uploadResult,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HomeScreenViewModel extends StateNotifier<HomeScreenState> {
  final Ref ref;
  final AssetUploadService _uploadService = AssetUploadService();

  HomeScreenViewModel(this.ref)
      : super(const HomeScreenState(
            templates: AsyncValue.loading(),
            filteredTemplates: [],
            searchQuery: '',
            selectedCategory: 'All')) {
    // Watch templates automatically
    _watchTemplates();
  }

  void _watchTemplates() {
    ref.listen<AsyncValue<List<TemplateEntity>>>(allTemplatesProvider,
        (previous, next) {
      final allTemplates = ref.read(allTemplatesProvider.notifier);
      state = state.copyWith(
        templates: next,
        hasMore: allTemplates.getHasMore(),
        isLoadingMore: allTemplates.getIsLoadingMore(),
      );
      next.when(
        data: (templates) => _applyFilters(templates),
        loading: () {},
        error: (error, stack) {},
      );
    });
  }

  void loadTemplates() {
    ref
        .read(allTemplatesProvider.notifier)
        .loadAllTemplates(forceRefresh: true);
  }

  void searchTemplates(String query) {
    state = state.copyWith(searchQuery: query);
    final templatesAsync = ref.read(allTemplatesProvider);
    templatesAsync.when(
      data: (templates) => _applyFilters(templates),
      loading: () {},
      error: (error, stack) {},
    );
  }

  void filterTemplates(String category) {
    state = state.copyWith(selectedCategory: category);
    final templatesAsync = ref.read(allTemplatesProvider);
    templatesAsync.when(
      data: (templates) => _applyFilters(templates),
      loading: () {},
      error: (error, stack) {},
    );
  }

  void resetSearch() {
    state = state.copyWith(searchQuery: '', selectedCategory: 'All');
    final templatesAsync = ref.read(allTemplatesProvider);
    templatesAsync.when(
      data: (templates) => _applyFilters(templates),
      loading: () {},
      error: (error, stack) {},
    );
  }

  Future<void> refreshTemplates() async {
    await ref.read(allTemplatesProvider.notifier).refresh();
  }

  Future<void> loadMoreTemplates() async {
    state = state.copyWith(isLoadingMore: true);
    await ref.read(allTemplatesProvider.notifier).loadMoreTemplates();
    // After loading more, update filteredTemplates
    final templatesAsync = ref.read(allTemplatesProvider);
    templatesAsync.when(
      data: (templates) => _applyFilters(templates),
      loading: () {},
      error: (error, stack) {},
    );
    final allTemplates = ref.read(allTemplatesProvider.notifier);
    state = state.copyWith(
      hasMore: allTemplates.getHasMore(),
      isLoadingMore: allTemplates.getIsLoadingMore(),
    );
  }

  void _applyFilters(List<TemplateEntity> templates) {
    List<TemplateEntity> filtered = templates;

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((template) =>
              template.name.toLowerCase().contains(query) ||
              template.category.toLowerCase().contains(query))
          .toList();
    }

    // Apply category filter
    if (state.selectedCategory != 'All') {
      filtered = filtered
          .where((template) => template.category
              .toLowerCase()
              .contains(state.selectedCategory.toLowerCase()))
          .toList();
    }

    state = state.copyWith(filteredTemplates: filtered);
  }

  // Asset upload functionality
  Future<void> uploadCardAssets() async {
    if (!_uploadService.isAuthenticated) {
      state = state.copyWith(
        uploadResult: const AsyncValue.error(
          'User must be authenticated to upload assets',
          StackTrace.empty,
        ),
      );
      return;
    }

    if (state.isUploading) {
      return; // Already uploading
    }

    state = state.copyWith(
      isUploading: true,
      uploadProgress: 'Initializing upload...',
      uploadResult: const AsyncValue.loading(),
    );

    try {
      final result = await _uploadService.uploadAllCardAssets(
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
        onError: (error) {
          // Individual errors are handled in the result
          print('Upload error: $error');
        },
      );

      state = state.copyWith(
        isUploading: false,
        uploadProgress: 'Upload completed!',
        uploadResult: AsyncValue.data(result),
      );

      // Refresh templates to show newly uploaded ones
      await refreshTemplates();
    } catch (e, stackTrace) {
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 'Upload failed!',
        uploadResult: AsyncValue.error(e, stackTrace),
      );
    }
  }

  // Get upload status
  Future<Map<String, dynamic>?> getUploadStatus() async {
    try {
      return await _uploadService.getUploadStatus();
    } catch (e) {
      return null;
    }
  }

  // Clear upload state
  void clearUploadState() {
    state = state.copyWith(
      isUploading: false,
      uploadProgress: '',
      uploadResult: const AsyncValue.data(null),
    );
  }

  // Clear all templates (admin function)
  Future<void> clearAllTemplates() async {
    if (!_uploadService.isAuthenticated) {
      throw Exception('User must be authenticated to clear templates');
    }

    try {
      await _uploadService.clearAllTemplates();
      await refreshTemplates();
    } catch (e) {
      rethrow;
    }
  }
}

final homeScreenViewModelProvider =
    StateNotifierProvider<HomeScreenViewModel, HomeScreenState>(
  (ref) => HomeScreenViewModel(ref),
);
