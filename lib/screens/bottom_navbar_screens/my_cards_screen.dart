import 'package:flutter/material.dart';
import 'package:mycards/data/template_data.dart';
import 'package:mycards/widgets/build_card_row.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  final List<Map<String, dynamic>> templates = templateData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Cards',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCardRow(
                context,
                title: 'Favorites',
                templates: templates,
              ),
              const SizedBox(height: 16),
              buildCardRow(
                context,
                title: 'Purchased',
                templates: templates,
              ),
              const SizedBox(height: 16),
              buildCardRow(
                context,
                title: 'Received',
                templates: templates,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
