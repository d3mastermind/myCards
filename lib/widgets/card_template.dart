import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycards/features/liked_cards/liked_card_provider.dart';
import 'package:mycards/features/my_cards/presentation/providers/my_cards_screen_vm.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_card_preview_page.dart';
import 'package:mycards/widgets/skeleton/image_skeleton.dart';

class CardTemplate extends ConsumerWidget {
  const CardTemplate({
    super.key,
    required this.template,
    this.onTap,
  });

  final Map<String, dynamic> template;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch if this card is liked
    final isLiked = ref.watch(isCardLikedProvider(template["templateId"]));
    final likedCardsNotifier = ref.read(likedCardsProvider.notifier);

    return Padding(
      padding: EdgeInsets.all(8.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card with enhanced shadow, image, and icons
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background image with enhanced styling
                  GestureDetector(
                    onTap: onTap ??
                        () {
                          // Default behavior - navigate to PreEditCardPreviewPage
                          print("Tapped on template ${template["templateId"]}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PreEditCardPreviewPage(template: template)),
                          );
                        },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CachedNetworkImage(
                        key: ValueKey(template["templateId"]), // Stable key
                        imageUrl: template["frontCover"],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        memCacheWidth: 400, // Optimize memory usage
                        memCacheHeight: 400,
                        maxWidthDiskCache: 400,
                        maxHeightDiskCache: 400,
                        cacheKey: template["templateId"], // Custom cache key
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFFE65100),
                                  size: 32.sp,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    color: Color(0xFF795548),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        progressIndicatorBuilder: (context, url, progress) =>
                            ImageSkeletonLoader(
                          width: 150,
                          height: 500,
                          borderRadius: 16,
                        ),
                      ),
                    ),
                  ),

                  // Premium icon with enhanced styling
                  if (template["ispremium"])
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: SizedBox(
                        width: 40.w,
                        height: 40.h,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(6.w),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Favorite icon with enhanced styling and toggle functionality
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      child: GestureDetector(
                        onTap: () async {
                          // Toggle like status
                          likedCardsNotifier.toggleLike(template["templateId"]);
                          await ref
                              .read(myCardsScreenViewModelProvider.notifier)
                              .refreshLikedCards();
                        },
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isLiked
                                    ? const [
                                        Color(0xFFFF5722),
                                        Color(0xFFFF7043)
                                      ]
                                    : [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.8)
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: isLiked
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(6.w),
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.white : Colors.red,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Template name with enhanced styling
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template["name"],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (template["ispremium"]) SizedBox(height: 4.h),
                if (template["ispremium"])
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Color(0xFFFFA000),
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFA000),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
