import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mycards/widgets/loading_indicators/pulse_loading_widget.dart';
import 'package:mycards/widgets/transaction_tile.dart';
import 'package:mycards/features/iap/presentation/providers/iap_providers.dart';
import 'package:mycards/features/iap/domain/entities/purchase_product.dart';
import 'credits_vm.dart';
import 'package:mycards/widgets/skeleton/transaction_skeleton_loader.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

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
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Custom App Bar
            Container(
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Credits',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.deepOrange.withOpacity(0.3),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh,
                              color: Colors.deepOrange),
                          onPressed: () {
                            ref
                                .read(creditsNotifierProvider.notifier)
                                .refresh();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(creditsNotifierProvider.notifier).refresh();
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // Credit Balance Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header with icon
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(40.r),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        creditBalance.when(
                                          data: (balance) => Text(
                                            "$balance CR",
                                            style: TextStyle(
                                              fontSize: 32.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFE65100),
                                            ),
                                          ),
                                          loading: () =>
                                              const PulseLoadingWidget(
                                            size: 50,
                                          ),
                                          error: (error, stack) => Text(
                                            "0 CR",
                                            style: TextStyle(
                                              fontSize: 32.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Available Balance",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF5722),
                                            Color(0xFFFF7043)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.orange.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: iapAvailable.when(
                                          data: (available) => available
                                              ? () => _showPurchaseDialog()
                                              : null,
                                          loading: () => null,
                                          error: (_, __) => null,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_shopping_cart_outlined,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "Buy Credits",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Container(
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFFC107),
                                            Color(0xFFFFB300)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.amber.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _showSendCreditsDialog(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.send,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              "Send Credits",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Show purchase/send status
                              SizedBox(height: 12.h),
                              _buildStatusIndicator(
                                  purchaseStatus, sendStatus, purchaseResult),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Transaction History Section Header
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE65100).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.history,
                                color: const Color(0xFFE65100),
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Recent Transactions",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Transaction List
                      transactionHistory.when(
                        loading: () => const TransactionSkeletonLoader(),
                        data: (transactions) {
                          if (transactions.isEmpty) {
                            return Container(
                              height: 200.h,
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(50.r),
                                      ),
                                      child: Icon(
                                        Icons.receipt_long,
                                        size: 40.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      "No transactions yet",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "Your transaction history will appear here",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              log("Transaction: ${transaction.description}");
                              return myTransactionTile(
                                amount:
                                    "${transaction.amount! > 0 ? '+' : ''}${transaction.amount} CR",
                                description: transaction.description ?? '',
                                date: _formatDate(transaction.createdAt!),
                                color: transaction.amount! > 0
                                    ? Colors.green
                                    : Colors.red,
                              );
                            },
                          );
                        },
                        error: (error, stack) => Container(
                          height: 200.h,
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16.r),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50.r),
                                ),
                                child: Icon(Icons.error_outline,
                                    color: Colors.red, size: 40.sp),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                "Error loading transactions",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                height: 36.h,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.red, Color(0xFFE57373)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(creditsNotifierProvider.notifier)
                                        .refresh();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Retry",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
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
      barrierDismissible: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final iapProducts = ref.watch(iapProductsProvider);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.orange,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Purchase Credits",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Choose your credit package",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, color: Colors.grey),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Content
                    iapProducts.when(
                      data: (products) {
                        if (products.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.orange,
                                    size: 48.sp,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  "No Products Available",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Make sure products are configured in Google Play Console.",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Text(
                              "Select a package that suits your needs",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            SizedBox(height: 20.h),
                            ...products
                                .map((product) => _buildProductTile(product)),
                          ],
                        );
                      },
                      loading: () => Container(
                        padding: EdgeInsets.all(32.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularLoadingWidget(
                              colors: [
                                Colors.orange,
                                Colors.orangeAccent,
                                Colors.deepOrange,
                                Colors.deepOrangeAccent
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "Loading Products...",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Please wait while we fetch available packages",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      error: (error, stackTrace) => Container(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48.sp,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "Error Loading Products",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Error Details:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    error.toString(),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12.r),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_outline,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Common Solutions:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildSolutionItem(
                                      "• Test on a real device with Google Play Services"),
                                  _buildSolutionItem(
                                      "• Upload app to Google Play Console"),
                                  _buildSolutionItem(
                                      "• Configure IAP products in Play Console"),
                                  _buildSolutionItem(
                                      "• Use a test account for testing"),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ref.invalidate(iapProductsProvider);
                                    },
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text("Retry"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showIAPDebugInfo(context),
                                    icon:
                                        const Icon(Icons.bug_report, size: 18),
                                    label: const Text("Debug Info"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductTile(PurchaseProduct product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: product.isPopular
              ? Colors.orange.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            final notifier = ref.read(iapNotifierProvider.notifier);
            Navigator.pop(context);
            // Use a microtask to ensure the navigation completes first
            Future.microtask(() {
              if (mounted) {
                notifier.purchaseProduct(product.id);
              }
            });
          },
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // Credit amount circle
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: product.isPopular
                              ? [Colors.orange, Colors.orange.shade700]
                              : [Colors.blue, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: (product.isPopular
                                    ? Colors.orange
                                    : Colors.blue)
                                .withOpacity(0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${product.credits}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${product.credits} Credits',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Price and arrow
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.price,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: product.isPopular
                                        ? Colors.orange.shade700
                                        : Colors.blue.shade700,
                                  ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Popular tag positioned at top-right
              if (product.isPopular)
                Positioned(
                  top: 0,
                  right: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.orange.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSendCreditsDialog() {
    final emailController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.send_outlined,
                        color: Colors.yellow,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Send Credits",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Share credits with friends",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Form fields
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Recipient Email",
                          hintText: "friend@example.com",
                          prefixIcon:
                              Icon(Icons.email_outlined, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 16.h),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: "Amount",
                          hintText: "10",
                          prefixIcon: Icon(Icons.attach_money_outlined,
                              color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 16.h),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final email = emailController.text.trim();
                          final amount =
                              int.tryParse(amountController.text.trim());

                          if (email.isNotEmpty &&
                              amount != null &&
                              amount > 0) {
                            ref
                                .read(creditsNotifierProvider.notifier)
                                .sendCredits(email, amount);
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Please enter valid email and amount"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Send",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
        title: Text("IAP Debug Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Check the console output for detailed debug messages."),
            SizedBox(height: 16.h),
            Text("IAP Availability:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            iapAvailable.when(
              data: (available) => Text(
                available ? "✅ Available" : "❌ Not Available",
                style: TextStyle(
                  color: available ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => Text("⏳ Checking..."),
              error: (error, _) => Text(
                "❌ Error: $error",
                style: const TextStyle(color: Colors.red),
              ),
            ),
            SizedBox(height: 16.h),
            Text("Platform Info:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text("Platform: ${Theme.of(context).platform}"),
            SizedBox(height: 16.h),
            Text("💡 Note:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "IAP only works on real devices with Google Play Services and "
              "when the app is uploaded to Google Play Console.",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
