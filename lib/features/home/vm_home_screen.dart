import 'package:mycards/features/templates/domain/entities/template_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/templates/presentation/providers/all_templates.dart';

class HomeScreenState {
  final AsyncValue<List<TemplateEntity>> templates;
  final List<TemplateEntity> filteredTemplates;
  final String searchQuery;
  final String selectedCategory;

  const HomeScreenState({
    required this.templates,
    required this.filteredTemplates,
    required this.searchQuery,
    required this.selectedCategory,
  });

  HomeScreenState copyWith({
    AsyncValue<List<TemplateEntity>>? templates,
    List<TemplateEntity>? filteredTemplates,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return HomeScreenState(
      templates: templates ?? this.templates,
      filteredTemplates: filteredTemplates ?? this.filteredTemplates,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class HomeScreenViewModel extends StateNotifier<HomeScreenState> {
  final Ref ref;

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
      state = state.copyWith(templates: next);
      next.when(
        data: (templates) => _applyFilters(templates),
        loading: () {},
        error: (error, stack) {},
      );
    });
  }

  void loadTemplates() {
    // Trigger a reload of templates
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

  void _applyFilters(List<TemplateEntity> allTemplates) {
    List<TemplateEntity> filtered = allTemplates;

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((template) =>
              template.name
                  .toLowerCase()
                  .contains(state.searchQuery.toLowerCase()) ||
              template.category
                  .toLowerCase()
                  .contains(state.searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter
    if (state.selectedCategory != 'All') {
      filtered = filtered
          .where((template) =>
              template.category.toLowerCase() ==
              state.selectedCategory.toLowerCase())
          .toList();
    }

    state = state.copyWith(filteredTemplates: filtered);
  }

  void resetSearch() {
    state = state.copyWith(searchQuery: '', selectedCategory: 'All');
    final templatesAsync = ref.read(allTemplatesProvider);
    templatesAsync.when(
      data: (templates) => state = state.copyWith(filteredTemplates: templates),
      loading: () {},
      error: (error, stack) {},
    );
  }

  Future<void> refreshTemplates() async {
    await ref.read(allTemplatesProvider.notifier).refresh();
  }
}

final homeScreenViewModelProvider =
    StateNotifierProvider<HomeScreenViewModel, HomeScreenState>(
  (ref) => HomeScreenViewModel(ref),
);
