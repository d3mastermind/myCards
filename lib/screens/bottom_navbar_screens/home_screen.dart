import 'package:flutter/material.dart';
import 'package:mycards/widgets/card_template.dart';
import 'package:mycards/widgets/category_item.dart';
import 'package:mycards/data/template_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> templates = templateData;
  List<Map<String, dynamic>> filteredTemplates =
      []; // For storing filtered results
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search bar

  @override
  void initState() {
    super.initState();
    filteredTemplates =
        templates; // Initialize filtered list with all templates
  }

  // Function to filter templates based on search query
  void _filterTemplates(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show all templates
        filteredTemplates = templates;
      } else {
        // Filter templates based on the query
        filteredTemplates = templates
            .where((template) =>
                template['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Function to reset the search
  void _resetSearch() {
    setState(() {
      _searchController.clear(); // Clear the search bar text
      filteredTemplates = templates; // Reset the filtered list to all templates
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    width: 140, // Adjust the width as needed
                    height: 80, // Adjust the height as needed
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(
                      width: 16), // Spacing between logo and search bar
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
                                onPressed: _resetSearch, // Reset the search
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged:
                          _filterTemplates, // Call filter function on text change
                    ),
                  ),
                ],
              ),
            ),
            // Rest of the body
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Popular Categories",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CategoryItem(
                              label: "Birthday",
                              icon: Icons.cake,
                              color: Colors.orange),
                          CategoryItem(
                              label: "Wedding",
                              icon: Icons.favorite,
                              color: Colors.pink),
                          CategoryItem(
                              label: "Christmas",
                              icon: Icons.square,
                              color: Colors.green),
                          CategoryItem(
                              label: "Ramadan",
                              icon: Icons.star,
                              color: Colors.purple),
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
                        itemCount: filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final template = filteredTemplates[index];
                          return CardTemplate(template: template);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
