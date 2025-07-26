import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/widgets/template_grid_view.dart';
import 'package:mycards/features/templates/presentation/providers/all_templates_pg.dart';
import 'vm_categories_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize templates loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allTemplatesProvider);
    });
  }

  void _filterCategories(String query) {
    ref
        .read(categoriesScreenViewModelProvider.notifier)
        .searchCategories(query);
  }

  void _resetSearch() {
    _searchController.clear();
    ref.read(categoriesScreenViewModelProvider.notifier).resetSearch();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesScreenViewModelProvider);
    final templatesAsync = ref.watch(allTemplatesProvider);
    final viewModel = ref.read(categoriesScreenViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'All Categories',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Categories',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: _resetSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.withAlpha(40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterCategories,
            ),
            const SizedBox(height: 16),
            // List of Categories
            Expanded(
              child: templatesAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading categories...'),
                    ],
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load categories',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.refreshTemplates();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (templates) {
                  final filteredCategories =
                      viewModel.filteredCategoriesComputed;

                  if (filteredCategories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            color: Colors.grey,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No categories found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search terms',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredCategories.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 0,
                      color: Colors.white,
                    ),
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final categoryTitle = category['title'].toString();
                      final templatesForCategory =
                          viewModel.getTemplatesAsMapForCategory(categoryTitle);

                      return ListTile(
                        leading: Icon(
                          category['icon'],
                          size: 30,
                          color: Colors.black,
                        ),
                        title: Text(
                          categoryTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          '${templatesForCategory.length} templates',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to TemplateGridScreen with filtered templates
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemplateGridScreen(
                                appBarTitle: categoryTitle,
                                templates: templatesForCategory,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
