import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';
import 'package:mycards/screens/bottom_navbar_screens/home_screen.dart';
import 'package:mycards/services/auth_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen(
      {super.key, required this.firebaseOtp, required this.phoneNumber});
  final String firebaseOtp;
  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
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
              onPressed: () async {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: widget.firebaseOtp,
                  smsCode: _otp,
                );
                await AuthService().signUpWithCredential(credential);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenController()),
                  (route) => false,
                );
              },
              child: Text('Verify'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                AuthService().signUpWithPhone(
                  widget.phoneNumber,
                  context,
                );
              },
              child: Text('Resend New Code'),
            ),
          ],
        ),
      ),
    );
  }
}
