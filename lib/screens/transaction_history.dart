import 'package:flutter/material.dart';
import 'package:mycards/widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            myTransactionTile(
              amount: "-15 CR",
              description: "Bought Card",
              date: "11/10/2024",
              color: Colors.red,
            ),
            myTransactionTile(
              amount: "+300 CR",
              description: "Purchased Credit",
              date: "12/10/2024",
              color: Colors.green,
            ),
            myTransactionTile(
              amount: "+200 CR",
              description: "From Ming",
              date: "11/22/2024",
              color: Colors.green,
            ),
            myTransactionTile(
              amount: "-100 CR",
              description: "To Zak Edward",
              date: "9/10/2024",
              color: Colors.red,
            ),
            myTransactionTile(
              amount: "-100 CR",
              description: "To Zak Edward",
              date: "9/10/2024",
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
