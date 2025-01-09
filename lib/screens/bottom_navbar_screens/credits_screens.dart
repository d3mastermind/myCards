import 'package:flutter/material.dart';
import 'package:mycards/widgets/transaction_tile.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  @override
  Widget build(BuildContext context) {
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Balance Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 350,
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
                  const Text(
                    "6000 CR",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Credit Balance",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 80,
                          child: ElevatedButton(
                            onPressed: () {
                              // Action for "Buy Credits"
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  color: Colors.white,
                                  Icons.add_shopping_cart_outlined,
                                  size: 50,
                                ),
                                Text(
                                  "Buy Credits",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          height: 80,
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              // Action for "Send Credit"
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Send Credit",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: Colors.black,
                                        fontSize: 24,
                                      ),
                                ),
                                Icon(
                                  color: Colors.black,
                                  Icons.send,
                                  size: 50,
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
                        fontSize: 18,
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        ],
      ),
    );
  }
}
