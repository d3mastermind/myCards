import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/account/account_screen.dart';
import 'package:mycards/features/account/user_state_notifier.dart';
import 'package:mycards/features/app_user/app_user_provider.dart';
import 'package:mycards/features/categories/categories_screen.dart';
import 'package:mycards/features/credits/credits_screens.dart';
import 'package:mycards/features/home/home_screen.dart';
import 'package:mycards/features/liked_cards/liked_card_provider.dart';
import 'package:mycards/features/my_cards/presentation/providers/my_cards_screen_vm.dart';
import 'package:mycards/features/my_cards/presentation/screens/my_cards_screen.dart';
import 'package:mycards/features/templates/presentation/providers/all_templates.dart';

class ScreenController extends ConsumerStatefulWidget {
  const ScreenController({super.key});

  @override
  ConsumerState<ScreenController> createState() => ScreenControllerState();
}

class ScreenControllerState extends ConsumerState<ScreenController> {
  @override
  void initState() {
    super.initState();
    AppUserService.instance.loadUser();
    // Initialize providers once when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allTemplatesProvider);
      ref.read(likedCardsProvider);
      // Load all templates in background
      ref.read(allTemplatesBackgroundProvider);
      ref.read(myCardsScreenViewModelProvider);
      ref.read(userStateNotifierProvider);

      // Credit service will be initialized automatically via providers
    });
  }

  int currentIndex = 2;

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Create screens once and keep them alive
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
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: currentIndex,
        color: Colors.red,
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.redAccent,
        height: 50,
        items: <Widget>[
          Image.asset(
            "assets/icon/category_icon.png",
            height: 26,
          ),
          Image.asset(
            "assets/icon/cards_icon.png",
            height: 26,
          ),
          Icon(Icons.home, size: 26, color: Colors.white),
          Image.asset(
            "assets/icon/accounts_icon.png",
            height: 26,
          ),
          Image.asset(
            "assets/icon/credits_icon.png",
            height: 26,
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
