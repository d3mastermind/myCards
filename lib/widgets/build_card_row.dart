import 'package:flutter/material.dart';
import 'package:mycards/widgets/card_template.dart';

Widget buildCardRow(
  BuildContext context, {
  required String title,
  required List<Map<String, dynamic>> templates,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         LargerScreen(title: title, templates: templates),
              //   ),
              // );
            },
            child: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: templates.length,
          itemBuilder: (context, index) {
            return TemplateCard(template: templates[index]);
          },
        ),
      ),
    ],
  );
}
