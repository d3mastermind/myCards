import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mycards/screens/account_screen.dart';
import 'package:mycards/screens/categories_screen.dart';
import 'package:mycards/screens/credits_screens.dart';
import 'package:mycards/screens/home_screen.dart';
import 'package:mycards/screens/my_cards_screen.dart';

class ScreenController extends StatefulWidget {
  const ScreenController({super.key});

  @override
  _ScreenControllerState createState() => _ScreenControllerState();
}

class _ScreenControllerState extends State<ScreenController> {
  int currentIndex = 3;

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
        color: Colors.red,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.redAccent,
        height: 60,
        items: <Widget>[
          Icon(Icons.category, size: 30, color: Colors.white),
          Icon(Icons.card_membership, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.account_circle, size: 30, color: Colors.white),
          Icon(Icons.credit_card, size: 30, color: Colors.white),
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
