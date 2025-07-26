import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_view.dart';
import 'package:mycards/features/account/profile_settings.dart';
import 'package:mycards/features/home/services/auth_service.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Account",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Profile Section
          const SizedBox(height: 16),
          //Profile Pic
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          // User Name
          // Consumer(
          //   builder: (context, ref, child) {
          //     final userAsync = ref.watch(currentUserProvider);
          //     return userAsync.when(
          //       data: (user) => Text(
          //         user?.name ?? user?.email ?? "User",
          //         style: const TextStyle(
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       loading: () => const CircularProgressIndicator(),
          //       error: (error, stack) => const Text(
          //         "User",
          //         style: TextStyle(
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     );
          //   },
          // ),
          // const SizedBox(height: 24),
          // // Account Information
          // Consumer(
          //   builder: (context, ref, child) {
          //     final creditBalanceAsync = ref.watch(userCreditBalanceProvider);
          //     return creditBalanceAsync.when(
          //       data: (balance) => ListTile(
          //         leading:
          //             const Icon(Icons.monetization_on, color: Colors.black),
          //         title: Text(
          //           "Credit Balance: $balance",
          //           style: const TextStyle(fontSize: 16),
          //         ),
          //       ),
          //       loading: () => const ListTile(
          //         leading: Icon(Icons.monetization_on, color: Colors.black),
          //         title: Text(
          //           "Loading...",
          //           style: TextStyle(fontSize: 16),
          //         ),
          //       ),
          //       error: (error, stack) => const ListTile(
          //         leading: Icon(Icons.monetization_on, color: Colors.black),
          //         title: Text(
          //           "Credit Balance: 0",
          //           style: TextStyle(fontSize: 16),
          //         ),
          //       ),
          //     );
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.history, color: Colors.black),
          //   title: const Text(
          //     "Transaction History",
          //     style: TextStyle(fontSize: 16),
          //   ),
          //   trailing: const Icon(Icons.arrow_forward, color: Colors.black),
          //   onTap: () {
          //     // Navigate to Transaction History page
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => TransactionHistoryScreen()),
          //     );
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.settings, color: Colors.black),
          //   title: const Text(
          //     "Profile Settings",
          //     style: TextStyle(fontSize: 16),
          //   ),
          //   trailing: const Icon(Icons.arrow_forward, color: Colors.black),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => ProfileSettings()),
          //     );
          //   },
          // ),
          // const Spacer(),
          // // Logout Button
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     SizedBox(
          //       width: 150,
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //         child: ElevatedButton.icon(
          //           onPressed: () async {
          //             await AuthService().signOut();
          //             Navigator.of(context).pushAndRemoveUntil(
          //               MaterialPageRoute(
          //                   builder: (context) => const PhoneLoginView()),
          //               (route) => false,
          //             );
          //           },
          //           icon: const Icon(Icons.logout, color: Colors.red),
          //           label: const Text(
          //             "Log Out",
          //             style: TextStyle(color: Colors.red),
          //           ),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.white,
          //             side: BorderSide(color: Colors.red.shade200, width: 1),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //             padding: const EdgeInsets.symmetric(vertical: 12),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),
          // // Footer Links
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 16.0),
          //   child: Column(
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           // Navigate to Contact Us page
          //         },
          //         child: const Text(
          //           "Contact Us",
          //           style: TextStyle(color: Colors.grey),
          //         ),
          //       ),
          //       const SizedBox(height: 8),
          //       GestureDetector(
          //         onTap: () {
          //           // Navigate to Privacy Policy page
          //         },
          //         child: const Text(
          //           "Privacy Policy",
          //           style: TextStyle(color: Colors.grey),
          //         ),
          //       ),
          //       const SizedBox(height: 8),
          //       GestureDetector(
          //         onTap: () {
          //           // Navigate to Terms of Service page
          //         },
          //         child: const Text(
          //           "Terms of Service",
          //           style: TextStyle(color: Colors.grey),
          //         ),
          //       ),
          //       SizedBox(
          //         height: 30,
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
