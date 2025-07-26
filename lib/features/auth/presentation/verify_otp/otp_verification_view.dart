import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';
import 'package:mycards/features/home/services/auth_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/presentation/verify_otp/otp_verification_vm.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen(
      {super.key, required this.firebaseOtp, required this.phoneNumber});
  final String firebaseOtp;
  final String phoneNumber;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  String _otp = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<OtpVerificationState>(otpVerificationVMProvider,
          (previous, next) {
        if (next.isSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ScreenController()),
            (route) => false,
          );
        } else if (next.isError && next.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage)),
          );
          ref.read(otpVerificationVMProvider.notifier).clearError();
        }
      });
    });
  }

  void _handleVerify() {
    ref
        .read(otpVerificationVMProvider.notifier)
        .verifyOtp(widget.firebaseOtp, _otp);
  }

  void _handleResend() {
    ref
        .read(otpVerificationVMProvider.notifier)
        .resendOtp(widget.phoneNumber, context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpVerificationVMProvider);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Verification',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 16.0),
            Text(
              'Enter the OTP code sent to your mobile number',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) {
                setState(() {
                  _otp = value;
                });
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8.0),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: state.isLoading ? null : _handleVerify,
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: _handleResend,
              child: const Text('Resend New Code'),
            ),
          ],
        ),
      ),
    );
  }
}
