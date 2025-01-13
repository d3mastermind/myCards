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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png'),
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search Designs",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
              SizedBox(height: 12),
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
                      label: "Ramadan", icon: Icons.star, color: Colors.purple),
                ],
              ),
              SizedBox(height: 16),
              //TemplateCard(template: templates[0]),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.45,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return TemplateCard(template: template);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
