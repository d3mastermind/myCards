//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycards/main.dart';
import 'package:mycards/services/auth_service.dart';

class EmailVerifyView extends StatelessWidget {
  const EmailVerifyView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 15),
                  'A verification mail has been sent to your email\nPlease verify to continue'),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  await AuthService().reloadUser();
                  bool? userVerified = AuthService().currentUser?.emailVerified;
                  if (userVerified != null && userVerified == true) {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyApp(),
                      ),
                    );
                    //print(" 1st ${user?.emailVerified}");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Email Hasn't Been Verified"),
                      ),
                    );
                  }
                },
                child: const Text('CONTINUE'),
              ),
              TextButton(
                onPressed: () async {
                  await AuthService().currentUser!.sendEmailVerification();
                },
                child: const Text('Didn\'t Receive mail? Resend'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
