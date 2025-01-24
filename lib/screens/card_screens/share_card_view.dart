import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

class ShareCardView extends StatefulWidget {
  const ShareCardView({super.key});

  @override
  State<ShareCardView> createState() => _ShareCardViewState();
}

class _ShareCardViewState extends State<ShareCardView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'US');
  String phoneNumber = "";

  void _shareViaEmail() {
    if (emailController.text.isNotEmpty) {
      // Add your email sharing logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Card shared successfully!")),
      );
    }
  }

  void _shareViaPhone() {
    if (phoneNumber.isNotEmpty) {
      // Add your phone sharing logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Card shared successfully!")),
      );
    }
  }

  void _shareViaSocialMedia() async {
    try {
      await Share.share(
        'Check out this amazing card!', // Your share message
        subject: 'Digital Card Share', // Email subject
        sharePositionOrigin: Rect.fromCircle(center: Offset(0, 0), radius: 10),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset("assets/animations/share.json",
                  repeat: true, height: 200),
              const Text(
                "Share the joy!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Send this card to the recipient via email or phone number.\nThe recipient will also receive 10 free credits from us to help you celebrate - Courtsey of Our Team",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(60),
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    labelText: "Email",
                    hintText: "Enter recipient's email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text("OR")),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(60),
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InternationalPhoneNumberInput(
                    initialValue: initialPhoneNumber,
                    inputDecoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                      hintText: "Phone number",
                      border: InputBorder.none,
                    ),
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        phoneNumber = number.phoneNumber!;
                      });
                      log(phoneNumber);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        if (emailController.text.isNotEmpty) {
                          _shareViaEmail();
                        } else if (phoneNumber.isNotEmpty) {
                          _shareViaPhone();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please enter an email or phone number."),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Share Card",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Or share via other social apps",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: _shareViaSocialMedia,
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.redAccent,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
