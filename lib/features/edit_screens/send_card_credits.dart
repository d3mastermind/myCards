import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/edit_screens/card_data_provider.dart';
import 'package:mycards/features/card_screens/card_page_view.dart';
import 'package:mycards/features/credits/credits_vm.dart';

class SendCardCreditsScreen extends ConsumerStatefulWidget {
  const SendCardCreditsScreen({
    super.key,
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
    if (cardData.creditsAttached > 0) {
      _selectedCredits = cardData.creditsAttached;
      _creditsController.text = (cardData.creditsAttached - 10).toString();
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
    final currentBalance = ref.read(creditBalanceValueProvider);
    if (_selectedCredits < currentBalance) {
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

  bool _isContinueButtonEnabled(int currentBalance) {
    return _selectedCredits >= 10 && _selectedCredits <= currentBalance;
  }

  void _handleFinishAndPreview() async {
    final cardData = ref.read(cardEditingProvider);

    // Validate required fields
    if (cardData.toName == null ||
        cardData.fromName == null ||
        cardData.greetingMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please fill in all required fields (To, From, and Greeting)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Update credits in provider
      ref.read(cardEditingProvider.notifier).updateCredits(_selectedCredits);

      // Save card to repository before preview
      await ref.read(cardEditingProvider.notifier).saveCardToRepository();

      // Navigate to preview
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardPageView(cardData: cardData),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSkip() async {
    final cardData = ref.read(cardEditingProvider);

    try {
      // Update provider with default credits
      ref.read(cardEditingProvider.notifier).updateCredits(10);

      // Save card to repository before preview
      await ref.read(cardEditingProvider.notifier).saveCardToRepository();

      // Navigate to preview with default credits
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardPageView(cardData: cardData),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider for changes
    final cardData = ref.watch(cardEditingProvider);
    final currentBalance = ref.watch(creditBalanceValueProvider);

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Give your card an extra special touch!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "The recipient will receive these credits after claiming the card. To help you celebrate, there's also free credits to be added, courtesy of our team!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF795548),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Balance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Credits Balance",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$currentBalance Credits",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      "Top Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Credits Input Section
            const Text(
              "Enter Credits to Attach:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _decrementCredits,
                      icon: const Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _creditsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _updateSelectedCredits,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _incrementCredits,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Credits Summary Card
            if (_selectedCredits >= 10)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Credits to be Attached",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF795548),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_selectedCredits - 10} + 10 = $_selectedCredits Credits",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isContinueButtonEnabled(currentBalance)
                            ? const [Color(0xFFFF5722), Color(0xFFFF7043)]
                            : [Colors.grey[400]!, Colors.grey[400]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isContinueButtonEnabled(currentBalance)
                          ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _isContinueButtonEnabled(currentBalance)
                          ? _handleFinishAndPreview
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Finish and Preview",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
