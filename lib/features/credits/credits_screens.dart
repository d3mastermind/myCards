import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/widgets/transaction_tile.dart';
import 'package:mycards/features/iap/presentation/providers/iap_providers.dart';
import 'package:mycards/features/iap/domain/entities/purchase_product.dart';
import 'credits_vm.dart';

class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(creditsNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final creditBalance = ref.watch(creditBalanceProvider);
    final transactionHistory = ref.watch(transactionHistoryProvider);
    final purchaseStatus = ref.watch(purchaseStatusProvider);
    final sendStatus = ref.watch(sendStatusProvider);
    final iapAvailable = ref.watch(iapAvailabilityProvider);
    final purchaseResult = ref.watch(purchaseResultProvider);

    // Listen to purchase results
    ref.listen<AsyncValue<dynamic>>(purchaseResultProvider, (previous, next) {
      next.whenData((result) {
        if (result != null) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Purchase successful! ${result.creditsAwarded ?? 0} credits added.'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh credits after successful purchase
            ref.read(creditsNotifierProvider.notifier).refresh();

            // Clear the purchase result after a short delay to ensure UI updates
            Future.delayed(const Duration(milliseconds: 1000), () {
              ref.read(iapNotifierProvider.notifier).clearState();
            });
          } else if (result.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Purchase failed: ${result.error}'),
                backgroundColor: Colors.red,
              ),
            );

            // Clear the purchase result after a short delay
            Future.delayed(const Duration(milliseconds: 1000), () {
              ref.read(iapNotifierProvider.notifier).clearState();
            });
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Credits",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents darkening effect when scrolling
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(creditsNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(creditsNotifierProvider.notifier).refresh();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Credit Balance Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 280,
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withAlpha(70),
                        blurRadius: 20,
                        offset: const Offset(6, -6),
                        blurStyle: BlurStyle.solid),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    creditBalance.when(
                      data: (balance) => Text(
                        "$balance CR",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => const Text(
                        "0 CR",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Credit Balance",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 220,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: iapAvailable.when(
                                data: (available) => available
                                    ? () => _showPurchaseDialog()
                                    : null,
                                loading: () => null,
                                error: (_, __) => null,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(
                                    color: Colors.white,
                                    Icons.add_shopping_cart_outlined,
                                    size: 36,
                                  ),
                                  Text(
                                    "Buy Credits",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 60,
                            width: 220,
                            child: ElevatedButton(
                              onPressed: () => _showSendCreditsDialog(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Send Credit",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                  ),
                                  const Icon(
                                    color: Colors.black,
                                    Icons.send,
                                    size: 36,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Show purchase/send status
                    const SizedBox(height: 8),
                    _buildStatusIndicator(
                        purchaseStatus, sendStatus, purchaseResult),
                  ],
                ),
              ),
            ),
            // Transaction History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.history, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Transaction List
            Expanded(
              child: transactionHistory.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text(
                        "No transactions yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return myTransactionTile(
                        amount:
                            "${transaction.amount > 0 ? '+' : ''}${transaction.amount} CR",
                        description:
                            _getTransactionDescription(transaction.type),
                        date: _formatDate(transaction.createdAt),
                        color:
                            transaction.amount > 0 ? Colors.green : Colors.red,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading transactions",
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(creditsNotifierProvider.notifier).refresh();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(AsyncValue<void> purchaseStatus,
      AsyncValue<void> sendStatus, AsyncValue<dynamic> iapStatus) {
    return Column(
      children: [
        purchaseStatus.when(
          data: (_) => const SizedBox.shrink(),
          loading: () => const Text("Processing...",
              style: TextStyle(color: Colors.orange)),
          error: (error, stack) => Text("Purchase failed: $error",
              style: const TextStyle(color: Colors.red)),
        ),
        sendStatus.when(
          data: (_) => const SizedBox.shrink(),
          loading: () => const Text("Sending credits...",
              style: TextStyle(color: Colors.orange)),
          error: (error, stack) => Text("Send failed: $error",
              style: const TextStyle(color: Colors.red)),
        ),
        iapStatus.when(
          data: (_) => const SizedBox.shrink(),
          loading: () => const Text("Processing purchase...",
              style: TextStyle(color: Colors.blue)),
          error: (error, stack) => Text("Purchase error: $error",
              style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _showPurchaseDialog() {
    // Invalidate the provider to ensure fresh data
    ref.invalidate(iapProductsProvider);

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final iapProducts = ref.watch(iapProductsProvider);

          return AlertDialog(
            title: const Text("Purchase Credits"),
            content: iapProducts.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, color: Colors.orange, size: 48),
                      SizedBox(height: 16),
                      Text("No products available"),
                      Text(
                          "Make sure products are configured in Google Play Console."),
                    ],
                  );
                }

                return SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Choose credit package:"),
                      const SizedBox(height: 16),
                      ...products.map((product) => _buildProductTile(product)),
                    ],
                  ),
                );
              },
              loading: () => const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading products..."),
                  SizedBox(height: 8),
                  Text("Check the console for debug info",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              error: (error, stackTrace) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading products",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Error details:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          error.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "💡 Common fixes:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "• Test on a real device with Google Play Services\n"
                          "• Upload app to Google Play Console\n"
                          "• Configure IAP products in Play Console\n"
                          "• Use a test account for testing",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.invalidate(iapProductsProvider);
                        },
                        child: const Text("Retry"),
                      ),
                      TextButton(
                        onPressed: () => _showIAPDebugInfo(context),
                        child: const Text("Debug Info"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductTile(PurchaseProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: product.isPopular ? Colors.orange : Colors.blue,
          child: Text(
            '${product.credits}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(product.title),
        subtitle: Text('${product.credits} Credits'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              product.price,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (product.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.of(context).pop();
          ref.read(iapNotifierProvider.notifier).purchaseProduct(product.id);
        },
      ),
    );
  }

  void _showSendCreditsDialog() {
    final emailController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Credits"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Recipient Email",
                hintText: "friend@example.com",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: "Amount",
                hintText: "10",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              final amount = int.tryParse(amountController.text.trim());

              if (email.isNotEmpty && amount != null && amount > 0) {
                ref
                    .read(creditsNotifierProvider.notifier)
                    .sendCredits(email, amount);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please enter valid email and amount")),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  String _getTransactionDescription(String? type) {
    switch (type) {
      case 'purchase':
        return 'Credits Purchased';
      case 'send':
        return 'Credits Sent';
      case 'receive':
        return 'Credits Received';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showIAPDebugInfo(BuildContext context) {
    final iapAvailable = ref.read(iapAvailabilityProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("IAP Debug Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Check the console output for detailed debug messages."),
            const SizedBox(height: 16),
            const Text("IAP Availability:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            iapAvailable.when(
              data: (available) => Text(
                available ? "✅ Available" : "❌ Not Available",
                style: TextStyle(
                  color: available ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const Text("⏳ Checking..."),
              error: (error, _) => Text(
                "❌ Error: $error",
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Platform Info:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Platform: ${Theme.of(context).platform}"),
            const SizedBox(height: 16),
            const Text("💡 Note:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
              "IAP only works on real devices with Google Play Services and "
              "when the app is uploaded to Google Play Console.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
