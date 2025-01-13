import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lottie/lottie.dart';

class ShareCardView extends StatefulWidget {
  const ShareCardView({super.key});

  @override
  State<ShareCardView> createState() => _ShareCardViewState();
}

class _ShareCardViewState extends State<ShareCardView> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'US');
    String phoneNumber = "";

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   title: const Text("Share the Card"),
      //   backgroundColor: Colors.orange,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //const SizedBox(height: 16),

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
              Center(child: Text("OR")),
              const SizedBox(height: 8),

              Container(
                //height: 50,
                decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(60),
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InternationalPhoneNumberInput(
                    initialValue: initialPhoneNumber,
                    inputDecoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                      hintText: "Phone number",
                      border: InputBorder.none,
                    ),
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType
                          .BOTTOM_SHEET, // Dropdown or bottom sheet
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
                        // Add sharing logic
                        String email = emailController.text;
                        String phone = phoneController.text;

                        if (email.isNotEmpty || phone.isNotEmpty) {
                          // Logic to send the card
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Card shared successfully!")),
                          );
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
                onPressed: () {},
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
