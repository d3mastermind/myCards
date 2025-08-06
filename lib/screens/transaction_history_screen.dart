import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycards/features/credits/credits_vm.dart';
import 'package:mycards/widgets/transaction_tile.dart';
import 'package:mycards/widgets/skeleton/transaction_skeleton_loader.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load transaction history when screen initializes
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(creditsNotifierProvider.notifier).loadTransactionHistory();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final transactionHistory = ref.watch(transactionHistoryProvider);

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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Transaction History',
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
                                .loadTransactionHistory();
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
                  await ref
                      .read(creditsNotifierProvider.notifier)
                      .loadTransactionHistory();
                },
                child: transactionHistory.when(
                  loading: () => _buildLoadingState(),
                  data: (transactions) => _buildTransactionList(transactions),
                  error: (error, stackTrace) =>
                      _buildErrorState(error.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const TransactionSkeletonLoader();
  }

  Widget _buildTransactionList(List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return Container(
        height: 200.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50.r),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: myTransactionTile(
            amount:
                "${transaction.amount! > 0 ? '+' : ''}${transaction.amount} CR",
            description: transaction.description ??
                _getTransactionDescription(transaction.type),
            date: _formatDate(transaction.createdAt!),
            color: transaction.amount! > 0 ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 200.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
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
            child: Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
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
                    .loadTransactionHistory();
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
      case 'cardPurchase':
        return 'Card Purchase';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
