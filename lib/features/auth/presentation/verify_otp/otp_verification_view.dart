import 'package:flutter/material.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/auth/presentation/verify_otp/otp_verification_vm.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

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
  }

  void _handleVerify() {
    AppLogger.log('OtpVerificationView: User initiated OTP verification',
        tag: 'OtpVerificationView');
    ref
        .read(otpVerificationVMProvider.notifier)
        .verifyOtp(widget.firebaseOtp, _otp);
  }

  void _handleResend() {
    AppLogger.log('OtpVerificationView: User requested OTP resend',
        tag: 'OtpVerificationView');
    ref
        .read(otpVerificationVMProvider.notifier)
        .resendOtp(widget.phoneNumber, context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpVerificationVMProvider);

    // Listen to state changes in build method
    ref.listen<OtpVerificationState>(otpVerificationVMProvider,
        (previous, next) {
      if (next.isSuccess) {
        AppLogger.logSuccess(
            'OtpVerificationView: OTP verification successful, navigating to home screen',
            tag: 'OtpVerificationView');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ScreenController()),
          (route) => false,
        );
        // Clear success state after navigation
        ref.read(otpVerificationVMProvider.notifier).clearSuccess();
      } else if (next.isError && next.errorMessage.isNotEmpty) {
        AppLogger.logError(
            'OtpVerificationView: OTP verification failed: ${next.errorMessage}',
            tag: 'OtpVerificationView');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage)),
        );
        ref.read(otpVerificationVMProvider.notifier).clearError();
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // OTP Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 60,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Enter Verification Code',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'We\'ve sent a 6-digit verification code to your mobile number.',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.grey[700],
                                    height: 1.6,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please enter the code below to verify your phone number.',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OTP Input
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: PinCodeTextField(
                        keyboardType: TextInputType.number,
                        appContext: context,
                        length: 6,
                        onChanged: (value) {
                          setState(() {
                            _otp = value;
                          });
                        },
                        cursorColor: const Color(0xFF6C63FF),
                        animationType: AnimationType.fade,
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: 60,
                          fieldWidth: 40,
                          borderWidth: 2,
                          activeFillColor: const Color(0xFFF8F9FA),
                          inactiveFillColor: const Color(0xFFF8F9FA),
                          selectedFillColor: const Color(0xFFF8F9FA),
                          activeColor: const Color(0xFF6C63FF),
                          inactiveColor: Colors.grey[300]!,
                          selectedColor: const Color(0xFF6C63FF),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularLoadingWidget(),
                            )
                          : Text(
                              'Verify Code',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resend Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _handleResend,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: const Color(0xFF6C63FF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Resend Verification Code',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Help text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.amber[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Code expires in 5 minutes. Check your messages.',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.amber[800],
                                      fontSize: 13,
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
        ),
      ),
    );
  }
}
