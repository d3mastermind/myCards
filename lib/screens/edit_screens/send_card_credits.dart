import 'package:flutter/material.dart';

class SendCardCreditsScreen extends StatefulWidget {
  final int currentBalance;

  const SendCardCreditsScreen({super.key, required this.currentBalance});

  @override
  State<SendCardCreditsScreen> createState() => _SendCardCreditsScreenState();
}

class _SendCardCreditsScreenState extends State<SendCardCreditsScreen> {
  final TextEditingController _creditsController = TextEditingController();
  int _selectedCredits = 0;

  @override
  void dispose() {
    // Dispose of the controller to free resources
    _creditsController.dispose();
    super.dispose();
  }

  void _updateSelectedCredits(String value) {
    setState(() {
      _selectedCredits = int.tryParse(value) ?? 0;
    });
  }

  void _incrementCredits() {
    if (_selectedCredits < widget.currentBalance) {
      setState(() {
        _selectedCredits++;
        _creditsController.text = _selectedCredits.toString();
      });
    }
  }

  void _decrementCredits() {
    if (_selectedCredits > 0) {
      setState(() {
        _selectedCredits--;
        _creditsController.text = _selectedCredits.toString();
      });
    }
  }

  bool get _isContinueButtonEnabled {
    return _selectedCredits > 0 && _selectedCredits <= widget.currentBalance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withAlpha(20),
      appBar: AppBar(
        leading: SizedBox(
          width: 0,
        ),
        title: const Text("Attach Credits to Card"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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

            // Credit Balance Display
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Credits: ${widget.currentBalance}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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

            // Input Field for Credits
            const Text(
              "Enter Credits to Attach:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Stepper for Increment/Decrement
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
                      hintText: "Enter credits",
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

            // Mini-preview (optional)
            if (_selectedCredits > 0)
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
                      Text(
                        "Credits to be Attached: $_selectedCredits + 10",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.card_giftcard, color: Colors.black),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Skip and Continue Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Skip action
                    Navigator.pop(context);
                  },
                  child: const Text("Skip"),
                ),
                ElevatedButton(
                  onPressed: _isContinueButtonEnabled
                      ? () {
                          // Proceed with attaching credits
                          print("Attached $_selectedCredits credits");
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text("Continue"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
