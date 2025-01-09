import 'package:flutter/material.dart';
import 'package:mycards/widgets/card_template.dart';

class TemplateGridScreen extends StatelessWidget {
  final String appBarTitle; // Title for the AppBar
  final List<Map<String, dynamic>> templates; // List of templates to display

  const TemplateGridScreen({
    super.key,
    required this.appBarTitle,
    required this.templates,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$appBarTitle Cards",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true, // Ensures text/icon color is black
      ),
      body: templates.isEmpty
          ? Center(
              child: Text(
                "No templates available.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.6, // Adjust as per your design
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return TemplateCard(template: template); // Custom card widget
                },
              ),
            ),
    );
  }
}
