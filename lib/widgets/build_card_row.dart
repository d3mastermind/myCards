import 'package:flutter/material.dart';
import 'package:mycards/widgets/card_template.dart';
import 'package:mycards/widgets/template_grid_view.dart';

class CardRow extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> templates;

  const CardRow({
    super.key,
    required this.title,
    required this.templates,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateGridScreen(
                    appBarTitle: title,
                    templates: templates,
                  ),
                ),
              );
            },
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplateGridScreen(
                              appBarTitle: title,
                              templates: templates,
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TemplateCard(
                      template: templates[index],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
