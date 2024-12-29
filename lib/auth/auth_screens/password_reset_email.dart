import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mycards/auth/auth_screens/phone_login_view.dart';

class PasswordResetEmailView extends StatelessWidget {
  const PasswordResetEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 400,
            child: Lottie.network(
                "https://lottie.host/0d404152-89a8-4b09-9f41-766caa2d8feb/yF8MuWVRPb.json"),
          ),
          SizedBox(
            child: Text(
              "A Password Reset Mail has \n been sent to your mail",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhoneLoginView(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.deepOrange),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  label: Text(
                    "Back to Log In",
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
