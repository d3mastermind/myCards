import 'package:flutter/material.dart';
import 'package:mycards/features/edit_screens/edit_card_screen.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_card_page_view.dart';
import 'package:mycards/widgets/loading_overlay.dart';

class PreEditCardPreviewPage extends StatefulWidget {
  final Map<String, dynamic> template;

  const PreEditCardPreviewPage({super.key, required this.template});

  @override
  State<PreEditCardPreviewPage> createState() => _PreEditCardPreviewPageState();
}

class _PreEditCardPreviewPageState extends State<PreEditCardPreviewPage> {
  bool isPurchased = false;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Card Preview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //const SizedBox(height: 16),

                const SizedBox(height: 8),
                // Card preview using CardPageView
                Expanded(
                  child: SizedBox(
                      width: 320,
                      child: PreEditCardPageView(
                        template: widget.template,
                        includeLastPage: false,
                      )),
                ),
                // Bottom section with card name, price, and purchase button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        widget.template["name"] ?? "Generic Card Name",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Price: ${widget.template["price"] ?? "0"} credits",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (!isPurchased) {
                                    await handlePurchase();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                )
                              : const Text(
                                  "Purchase and Customize",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }

  Future<void> handlePurchase() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditCardPage(
            template: widget.template,
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = 'Failed to purchase template. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
