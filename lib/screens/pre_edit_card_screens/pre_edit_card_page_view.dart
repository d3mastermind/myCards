import 'package:flutter/material.dart';
import 'package:mycards/screens/card_screens/front_cover.dart';
import 'package:mycards/screens/card_screens/share_card_view.dart';
import 'package:mycards/screens/pre_edit_card_screens/pre_edit_5th_page.dart';
import 'package:mycards/screens/pre_edit_card_screens/pre_edit_2nd_page.dart';
import 'package:mycards/screens/pre_edit_card_screens/pre_edit_3rd_page.dart';
import 'package:mycards/screens/pre_edit_card_screens/pre_edit_4th_page.dart';

class PreEditCardPageView extends StatefulWidget {
  const PreEditCardPageView(
      {super.key, required this.template, required this.includeLastPage});
  final Map<String, dynamic> template;
  final bool includeLastPage;

  @override
  State<PreEditCardPageView> createState() => _PreEditCardPageViewState();
}

class _PreEditCardPageViewState extends State<PreEditCardPageView> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String frontCoverImageUrl = widget.template["frontCover"];

    final pages = [
      FrontCoverView(
        image: frontCoverImageUrl,
      ),
      PreEdit2ndPage(bgImageUrl: frontCoverImageUrl),
      PreEdit3rdPage(),
      PreEdit4thPage(
        audioUrl: "audio/defaultaudio.mp3",
        bgImageUrl: frontCoverImageUrl,
      ),
      if (widget.includeLastPage) ShareCardView(),
      PreEdit5thPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pages[index],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.orange
                        : Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
