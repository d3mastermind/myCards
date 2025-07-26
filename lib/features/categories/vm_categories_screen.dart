import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/templates/domain/entities/template_entity.dart';
import 'package:mycards/features/templates/presentation/providers/all_templates.dart';
import 'package:mycards/data/category_list.dart';

class CategoriesScreenState {
  final AsyncValue<List<TemplateEntity>> templates;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> filteredCategories;
  final String searchQuery;

  const CategoriesScreenState({
    required this.templates,
    required this.categories,
    required this.filteredCategories,
    required this.searchQuery,
  });

  CategoriesScreenState copyWith({
    AsyncValue<List<TemplateEntity>>? templates,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? filteredCategories,
    String? searchQuery,
  }) {
    return CategoriesScreenState(
      templates: templates ?? this.templates,
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CategoriesScreenViewModel extends StateNotifier<CategoriesScreenState> {
  final Ref ref;

  CategoriesScreenViewModel(this.ref)
      : super(CategoriesScreenState(
            templates: const AsyncValue.loading(),
            categories: categoryList,
            filteredCategories: categoryList,
            searchQuery: ''));

  // Get current templates state from background provider (all templates)
  AsyncValue<List<TemplateEntity>> get templatesState =>
      ref.read(allTemplatesBackgroundProvider);

  // Get filtered categories based on available templates
  List<Map<String, dynamic>> get availableCategories {
    return templatesState.when(
      data: (templates) {
        final Set<String> availableCategories = templates
            .map((template) => template.category.toLowerCase())
            .toSet();

        return categoryList.where((category) {
          final categoryTitle = category['title'].toString().toLowerCase();
          return availableCategories.any((availableCategory) =>
              availableCategory.contains(categoryTitle) ||
              categoryTitle.contains(availableCategory));
        }).toList();
      },
      loading: () => categoryList,
      error: (error, stack) => categoryList,
    );
  }

  void searchCategories(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<Map<String, dynamic>> get filteredCategoriesComputed {
    final categories = availableCategories;
    if (state.searchQuery.isEmpty) {
      return categories;
    }

    return categories
        .where((category) => category['title']
            .toString()
            .toLowerCase()
            .contains(state.searchQuery.toLowerCase()))
        .toList();
  }

  void resetSearch() {
    state = state.copyWith(searchQuery: '');
  }

  // Get templates for a specific category
  List<TemplateEntity> getTemplatesForCategory(String categoryTitle) {
    return templatesState.when(
      data: (templates) {
        final categoryLower = categoryTitle.toLowerCase();
        return templates.where((template) {
          final templateCategory = template.category.toLowerCase();
          return templateCategory.contains(categoryLower) ||
              categoryLower.contains(templateCategory);
        }).toList();
      },
      loading: () => [],
      error: (error, stack) => [],
    );
  }

  // Convert TemplateEntity list to Map list for backward compatibility
  List<Map<String, dynamic>> getTemplatesAsMapForCategory(
      String categoryTitle) {
    final templates = getTemplatesForCategory(categoryTitle);
    return templates
        .map((template) => {
              'templateId': template.templateId,
              'name': template.name,
              'category': template.category,
              'ispremium': template.isPremium,
              'price': template.price,
              'frontCover': template.frontCover,
            })
        .toList();
  }

  Future<void> refreshTemplates() async {
    await ref.read(allTemplatesBackgroundProvider.notifier).refresh();
  }
}

final categoriesScreenViewModelProvider =
    StateNotifierProvider<CategoriesScreenViewModel, CategoriesScreenState>(
  (ref) => CategoriesScreenViewModel(ref),
);
