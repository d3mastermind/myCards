import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/liked_cards/liked_card_provider.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_card_preview_page.dart';

class CardTemplate extends ConsumerWidget {
  const CardTemplate({
    super.key,
    required this.template,
  });

  final Map<String, dynamic> template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch if this card is liked
    final isLiked = ref.watch(isCardLikedProvider(template["templateId"]));
    final likedCardsNotifier = ref.read(likedCardsProvider.notifier);

    return GestureDetector(
      onTap: () {
        print("Tapped on template ${template["templateId"]}");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreEditCardPreviewPage(template: template)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card with shadow, image, and icons
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(70),
                      blurRadius: 8,
                      offset: Offset(10, -10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    // Premium icon
                    if (template["ispremium"])
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 20,
                          ),
                        ),
                      ),
                    // Favorite icon with toggle functionality
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          // Toggle like status
                          likedCardsNotifier.toggleLike(template["templateId"]);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Template name below the image
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                template["name"],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
