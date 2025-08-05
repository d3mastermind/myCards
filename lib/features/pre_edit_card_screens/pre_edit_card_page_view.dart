import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycards/features/card_screens/front_cover.dart';
import 'package:mycards/features/card_screens/share_card_view.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_5th_page.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_2nd_page.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_3rd_page.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_4th_page.dart';

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
        isUrl: true,
      ),
      PreEdit2ndPage(
        bgImageUrl: frontCoverImageUrl,
        isUrl: true,
      ),
      PreEdit3rdPage(),
      PreEdit4thPage(
        audioUrl: "audio/defaultaudio.mp3",
        bgImageUrl: frontCoverImageUrl,
      ),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0.w, vertical: 8.h),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: pages[index],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 16.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.orange
                        : Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
