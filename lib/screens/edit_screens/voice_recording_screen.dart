import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/providers/card_data_provider.dart';

class VoiceRecordingScreen extends StatefulWidget {
  const VoiceRecordingScreen({super.key, required this.provider});
  final StateNotifierProvider<CardDataNotifier, CardData> provider;

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
