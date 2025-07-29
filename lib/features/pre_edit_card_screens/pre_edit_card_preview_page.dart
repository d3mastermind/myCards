import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/edit_screens/edit_card_screen.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_card_page_view.dart';
import 'package:mycards/features/credits/credits_vm.dart';
import 'package:mycards/widgets/loading_overlay.dart';

class PreEditCardPreviewPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> template;

  const PreEditCardPreviewPage({super.key, required this.template});

  @override
  ConsumerState<PreEditCardPreviewPage> createState() =>
      _PreEditCardPreviewPageState();
}

class _PreEditCardPreviewPageState
    extends ConsumerState<PreEditCardPreviewPage> {
  bool isPurchased = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Load credit balance when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(creditsNotifierProvider.notifier).loadCreditBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch credit balance
    final creditBalance = ref.watch(creditBalanceValueProvider);
    final creditsNotifier = ref.read(creditsNotifierProvider.notifier);

    // Get card price from template
    final cardPrice = widget.template["price"] ?? 0;
    final cardName = widget.template["name"] ?? "Generic Card Name";

    // Check if user has sufficient credits
    final hasSufficientCredits = creditBalance >= cardPrice;

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
                        cardName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Price: $cardPrice credits",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Show current balance
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Balance: $creditBalance credits",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isLoading ||
                                  isPurchased ||
                                  !hasSufficientCredits)
                              ? null
                              : () async {
                                  if (!isPurchased) {
                                    await handlePurchase(cardPrice);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasSufficientCredits
                                ? Colors.yellow
                                : Colors.grey,
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
                              : Text(
                                  isPurchased
                                      ? "Purchased ✓"
                                      : hasSufficientCredits
                                          ? "Purchase and Customize"
                                          : "Insufficient Credits",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: hasSufficientCredits
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      // Show error message if any
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _error = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Show insufficient credits message
                      if (!hasSufficientCredits && _error == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_outlined,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "You need ${cardPrice - creditBalance} more credits to purchase this card",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  Future<void> handlePurchase(int cardPrice) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final creditsNotifier = ref.read(creditsNotifierProvider.notifier);
      final success = await creditsNotifier.purchaseCard(cardPrice);

      if (success) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to edit card screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCardPage(
                template: widget.template,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Failed to purchase card - insufficient credits';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to purchase card: $e';
        _isLoading = false;
      });
    }
  }
}
