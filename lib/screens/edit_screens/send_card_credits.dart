import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/providers/card_data_provider.dart';
import 'package:mycards/screens/card_screens/card_page_view.dart';

class SendCardCreditsScreen extends ConsumerStatefulWidget {
  final int currentBalance;
  const SendCardCreditsScreen({
    super.key,
    required this.currentBalance,
  });

  @override
  ConsumerState<SendCardCreditsScreen> createState() =>
      _SendCardCreditsScreenState();
}

class _SendCardCreditsScreenState extends ConsumerState<SendCardCreditsScreen> {
  final TextEditingController _creditsController = TextEditingController();
  int _selectedCredits = 10; // Default value as specified

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the default extra credits (excluding the free 10)
    _creditsController.text = '0';

    // Get initial credits from provider if available
    final cardData = ref.read(cardEditingProvider);
    if (cardData.creditsAttached != null) {
      _selectedCredits = cardData.creditsAttached!;
      _creditsController.text = (cardData.creditsAttached! - 10).toString();
    }
  }

  @override
  void dispose() {
    _creditsController.dispose();
    super.dispose();
  }

  void _updateSelectedCredits(String value) {
    final extraCredits = int.tryParse(value) ?? 0;
    setState(() {
      _selectedCredits = extraCredits + 10; // Add the free credits
    });

    // Update the provider
    ref.read(cardEditingProvider.notifier).updateCredits(_selectedCredits);
  }

  void _incrementCredits() {
    if (_selectedCredits < widget.currentBalance) {
      setState(() {
        _selectedCredits++;
        _creditsController.text = (_selectedCredits - 10).toString();
      });
      ref.read(cardEditingProvider.notifier).updateCredits(_selectedCredits);
    }
  }

  void _decrementCredits() {
    if (_selectedCredits > 10) {
      // Don't go below the free credits
      setState(() {
        _selectedCredits--;
        _creditsController.text = (_selectedCredits - 10).toString();
      });
      ref.read(cardEditingProvider.notifier).updateCredits(_selectedCredits);
    }
  }

  bool get _isContinueButtonEnabled {
    return _selectedCredits >= 10 && _selectedCredits <= widget.currentBalance;
  }

  void _handleFinishAndPreview() {
    final cardData = ref.read(cardEditingProvider);
    // if (cardData == null) {
    //   // Show error if no card data exists
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Error: Card data not found')),
    //   );
    //   return;
    // }

    // Create final CardData object with all previous data plus credits
    final finalCardData = cardData.copyWith(
      creditsAttached: _selectedCredits,
    );
    if (finalCardData.creditsAttached == null ||
        finalCardData.to == null ||
        finalCardData.from == null ||
        finalCardData.greeting == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: please fill all fields')),
      );
      return;
    }

    // Navigate to preview
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardPageView(cardData: finalCardData),
      ),
    );
  }

  void _handleSkip() {
    final cardData = ref.read(cardEditingProvider);
    if (cardData != null) {
      // Update provider with default credits
      ref.read(cardEditingProvider.notifier).updateCredits(10);

      // Navigate to preview with default credits
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardPageView(
            cardData: cardData.copyWith(creditsAttached: 10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Card data not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider for changes
    final cardData = ref.watch(cardEditingProvider);

    return Scaffold(
      backgroundColor: Colors.grey.withAlpha(20),
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text("Attach Credits to Card"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Give your card an extra special touch by attaching credits! The recipient will receive these credits after claiming the card.\n\n"
                "To help you celebrate, there's also free credits to be added, courtesy of our team!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Your Credits Balance: ${widget.currentBalance}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to Top-Up Screen
                          print("Top-Up Credits");
                        },
                        child: const Text("Top Up"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Enter Credits to Attach:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _decrementCredits,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _creditsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter additional credits",
                      ),
                      onChanged: _updateSelectedCredits,
                    ),
                  ),
                  IconButton(
                    onPressed: _incrementCredits,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedCredits >= 10)
                Card(
                  color: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Credits to be Attached: ${_selectedCredits - 10} + 10",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.card_giftcard, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextButton(
                      onPressed: _handleSkip,
                      child: const Text("Skip"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isContinueButtonEnabled
                          ? _handleFinishAndPreview
                          : null,
                      child: const Text("Finish and Preview"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
