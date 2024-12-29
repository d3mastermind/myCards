import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                children: [
                  Image.asset('assets/images/logo.png'),
                  Positioned(
                    top: 100,
                    left: 100,
                    child: Text(
                      "Design. Share. Smile.",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 400,
              child: Lottie.asset("assets/animations/getstarted.json"),
            ),
            Row(
              children: [
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.amberAccent,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: Text(
                      "Start Now",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
