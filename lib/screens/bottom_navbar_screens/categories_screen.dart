import 'package:flutter/material.dart';
import 'package:mycards/data/category_list.dart';
import 'package:mycards/data/template_data.dart';
import 'package:mycards/widgets/template_grid_view.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List categories = [];
  List filteredCategories = []; // For storing filtered results
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search bar

  @override
  void initState() {
    categories = categoryList;
    filteredCategories =
        categories; // Initialize filtered list with all categories
    super.initState();
  }

  // Function to filter categories based on search query
  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show all categories
        filteredCategories = categories;
      } else {
        // Filter categories based on the query
        filteredCategories = categories
            .where((category) =>
                category['title'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear(); // Clear the search bar text
      filteredCategories =
          categories; // Reset the filtered list to all categories
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: _resetSearch, // Reset the search
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.withAlpha(40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged:
                  _filterCategories, // Call filter function on text change
            ),
            const SizedBox(height: 16),
            // List of Categories
            Expanded(
              child: ListView.separated(
                itemCount: filteredCategories.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 0,
                  color: Colors.white,
                ),
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return ListTile(
                    leading: Icon(
                      category['icon'],
                      size: 30,
                      color: Colors.black,
                    ),
                    title: Text(category['title'],
                        style: Theme.of(context).textTheme.titleLarge),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to TemplateGridScreen with the selected category
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateGridScreen(
                            appBarTitle: "${category['title']}",
                            templates: templateData,
                          ),
                        ),
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
}
