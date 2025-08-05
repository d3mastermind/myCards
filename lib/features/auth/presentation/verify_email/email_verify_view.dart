//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycards/main.dart';
import 'package:mycards/features/home/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/presentation/verify_email/email_verify_vm.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

class EmailVerifyView extends ConsumerWidget {
  const EmailVerifyView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emailVerifyVMProvider);
    ref.listen<EmailVerifyState>(emailVerifyVMProvider, (previous, next) {
      if (next.isSuccess) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyApp(),
          ),
        );
      } else if (next.isError && next.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage)),
        );
        ref.read(emailVerifyVMProvider.notifier).clearError();
      }
    });
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
                onPressed: state.isLoading
                    ? null
                    : () => ref
                        .read(emailVerifyVMProvider.notifier)
                        .reloadAndVerify(),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularLoadingWidget(),
                      )
                    : const Text('CONTINUE'),
              ),
              TextButton(
                onPressed: () => ref
                    .read(emailVerifyVMProvider.notifier)
                    .resendVerification(),
                child: const Text('Didn\'t Receive mail? Resend'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
