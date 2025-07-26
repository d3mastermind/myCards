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
  final ScrollController _scrollController = ScrollController();
  bool _showAdminPanel = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final homeState = ref.read(homeScreenViewModelProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        homeState.hasMore &&
        !homeState.isLoadingMore) {
      ref.read(homeScreenViewModelProvider.notifier).loadMoreTemplates();
    }
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

  // Toggle admin panel
  void _toggleAdminPanel() {
    setState(() {
      _showAdminPanel = !_showAdminPanel;
    });
  }

  // Upload assets function
  Future<void> _uploadAssets() async {
    await ref.read(homeScreenViewModelProvider.notifier).uploadCardAssets();
  }

  // Show upload result dialog
  void _showUploadResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Results'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Processed: ${result['totalProcessed']}'),
              Text('Successful: ${result['successful']}',
                  style: const TextStyle(color: Colors.green)),
              Text('Failed: ${result['failed']}',
                  style: const TextStyle(color: Colors.red)),
              if (result['errors'].isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Errors:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...result['errors']
                    .map<Widget>((error) => Text('• $error',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.red)))
                    .toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                  // Logo (with long press for admin panel)
                  GestureDetector(
                    onLongPress: () {}, //_toggleAdminPanel,
                    child: SizedBox(
                      width: 110,
                      height: 60,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
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

            // Admin Panel (only shown when toggled)
            if (_showAdminPanel) _buildAdminPanel(homeState),

            // Rest of the body
            Expanded(
              child: _buildBody(homeState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPanel(HomeScreenState homeState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Admin Panel',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleAdminPanel,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Upload Status
          FutureBuilder<Map<String, dynamic>?>(
            future: ref
                .read(homeScreenViewModelProvider.notifier)
                .getUploadStatus(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final status = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Status:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Total Assets: ${status['totalAssets']}'),
                    Text('Uploaded: ${status['uploadedTemplates']}'),
                    Text('Remaining: ${status['remainingAssets']}'),
                    const SizedBox(height: 8),
                  ],
                );
              }
              return const Text('Loading status...');
            },
          ),

          // Upload Progress
          if (homeState.isUploading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(homeState.uploadProgress,
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
          ],

          // Upload Result
          homeState.uploadResult.when(
            data: (result) {
              if (result != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showUploadResultDialog(result);
                  ref
                      .read(homeScreenViewModelProvider.notifier)
                      .clearUploadState();
                });
              }
              return const SizedBox.shrink();
            },
            loading: () => const Text('Processing upload...'),
            error: (error, stack) => Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: homeState.isUploading ? null : _uploadAssets,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Upload Assets'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: homeState.isUploading ? null : _refreshTemplates,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ],
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
            controller: _scrollController,
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
                      final templateMap = _templateEntityToMap(template);
                      return CardTemplate(
                        template: templateMap,
                        key: ValueKey(
                          template.templateId,
                        ),
                      );
                    },
                  ),
                  if (homeState.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (homeState.hasMore && !homeState.isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: homeState.isLoadingMore
                              ? null
                              : () {
                                  ref
                                      .read(
                                          homeScreenViewModelProvider.notifier)
                                      .loadMoreTemplates();
                                },
                          child: const Text('Load More'),
                        ),
                      ),
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
    _scrollController.dispose();
    super.dispose();
  }
}
