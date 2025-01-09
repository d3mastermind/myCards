import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mycards/screens/bottom_navbar_screens/account_screen.dart';
import 'package:mycards/screens/bottom_navbar_screens/categories_screen.dart';
import 'package:mycards/screens/bottom_navbar_screens/credits_screens.dart';
import 'package:mycards/screens/bottom_navbar_screens/home_screen.dart';
import 'package:mycards/screens/bottom_navbar_screens/my_cards_screen.dart';

class ScreenController extends StatefulWidget {
  const ScreenController({super.key});

  @override
  ScreenControllerState createState() => ScreenControllerState();
}

class ScreenControllerState extends State<ScreenController> {
  int currentIndex = 2;

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> screens = [
    CategoriesScreen(),
    MyCardsScreen(),
    HomeScreen(),
    AccountScreen(),
    CreditsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: currentIndex,
        color: Colors.red,
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.redAccent,
        height: 60,
        items: <Widget>[
          Image.asset(
            "assets/icons/category_icon.png",
            height: 30,
          ),
          Image.asset(
            "assets/icons/cards_icon.png",
            height: 30,
          ),
          Icon(Icons.home, size: 30, color: Colors.white),
          Image.asset(
            "assets/icons/accounts_icon.png",
            height: 30,
          ),
          Image.asset(
            "assets/icons/credits_icon.png",
            height: 30,
          ),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
