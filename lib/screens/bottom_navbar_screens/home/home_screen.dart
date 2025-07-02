import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/widgets/card_template.dart';
import 'package:mycards/widgets/category_item.dart';
import 'package:mycards/features/templates/domain/entities/template_entity.dart';
import 'package:mycards/features/templates/presentation/providers/all_templates.dart';
import 'vm_home_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load templates when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Just access the provider to trigger initial load, no need to call loadTemplates
      ref.read(allTemplatesProvider);
    });
  }

  // Function to filter templates based on search query
  void _filterTemplates(String query) {
    ref.read(homeScreenViewModelProvider.notifier).searchTemplates(query);
  }

  // Function to reset the search
  void _resetSearch() {
    _searchController.clear();
    ref.read(homeScreenViewModelProvider.notifier).resetSearch();
  }

  // Function to refresh templates
  Future<void> _refreshTemplates() async {
    await ref.read(homeScreenViewModelProvider.notifier).refreshTemplates();
  }

  // Function to filter by category
  void _filterByCategory(String category) {
    ref.read(homeScreenViewModelProvider.notifier).filterTemplates(category);
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeScreenViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar with Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  // Logo
                  SizedBox(
                    width: 110,
                    height: 60,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search Bar
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search Designs",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.grey),
                                onPressed: _resetSearch,
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: _filterTemplates,
                    ),
                  ),
                ],
              ),
            ),
            // Rest of the body
            Expanded(
              child: _buildBody(homeState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(HomeScreenState homeState) {
    return homeState.templates.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading templates...'),
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
              'Failed to load templates',
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
                ref.read(homeScreenViewModelProvider.notifier).loadTemplates();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (templates) {
        if (homeState.filteredTemplates.isEmpty) {
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
                  templates.isEmpty
                      ? 'No templates available'
                      : 'No templates found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  templates.isEmpty
                      ? 'Check back later for new templates'
                      : 'Try adjusting your search terms',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (templates.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshTemplates,
                    child: const Text('Refresh'),
                  ),
                ]
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshTemplates,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Popular Categories",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => _filterByCategory("Birthday"),
                        child: CategoryItem(
                            label: "Birthday",
                            icon: Icons.cake,
                            color: Colors.orange),
                      ),
                      GestureDetector(
                        onTap: () => _filterByCategory("Wedding"),
                        child: CategoryItem(
                            label: "Wedding",
                            icon: Icons.favorite,
                            color: Colors.pink),
                      ),
                      GestureDetector(
                        onTap: () => _filterByCategory("Christmas"),
                        child: CategoryItem(
                            label: "Christmas",
                            icon: Icons.square,
                            color: Colors.green),
                      ),
                      GestureDetector(
                        onTap: () => _filterByCategory("Ramadan"),
                        child: CategoryItem(
                            label: "Ramadan",
                            icon: Icons.star,
                            color: Colors.purple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 0.5,
                    ),
                    itemCount: homeState.filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = homeState.filteredTemplates[index];
                      // Convert TemplateEntity to Map for backward compatibility
                      final templateMap = _templateEntityToMap(template);
                      return CardTemplate(template: templateMap);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to convert TemplateEntity to Map for backward compatibility
  Map<String, dynamic> _templateEntityToMap(TemplateEntity template) {
    return {
      'templateId': template.templateId,
      'name': template.name,
      'category': template.category,
      'ispremium': template.isPremium,
      'price': template.price,
      'frontCover': template.frontCover,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
