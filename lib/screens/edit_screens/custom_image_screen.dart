import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/providers/card_data_provider.dart';

class CustomImageScreen extends StatefulWidget {
  const CustomImageScreen({super.key, required this.provider});
  final StateNotifierProvider<CardDataNotifier, CardData> provider;

  @override
  State<CustomImageScreen> createState() => _CustomImageScreenState();
}

class _CustomImageScreenState extends State<CustomImageScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
