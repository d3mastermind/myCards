import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycards/features/my_cards/presentation/providers/my_cards_screen_vm.dart';
import 'package:mycards/widgets/build_card_row.dart';
import 'package:mycards/features/cards/domain/card_entity.dart';
import 'package:mycards/features/templates/domain/entities/template_entity.dart';
import 'package:mycards/features/edit_screens/edit_card_screen.dart';
import 'package:mycards/features/card_screens/card_page_view.dart';
import 'package:mycards/features/edit_screens/card_data_provider.dart';
import 'package:mycards/features/pre_edit_card_screens/pre_edit_card_preview_page.dart';
import 'package:mycards/widgets/card_template.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';
import 'package:mycards/widgets/template_grid_view.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myCardsState = ref.watch(myCardsScreenViewModelProvider);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Custom App Bar
            Container(
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'My Cards',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.deepOrange.withOpacity(0.3),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh,
                              color: Colors.deepOrange),
                          onPressed: () {
                            ref
                                .read(myCardsScreenViewModelProvider.notifier)
                                .refresh();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(myCardsScreenViewModelProvider.notifier)
                      .refresh();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),

                        // Liked Cards Section
                        _buildLikedCardsSection(context, ref, myCardsState),
                        SizedBox(height: 24.h),

                        // Purchased Cards Section
                        _buildPurchasedCardsSection(context, ref, myCardsState),
                        SizedBox(height: 24.h),

                        // Received Cards Section
                        _buildReceivedCardsSection(context, ref, myCardsState),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build section headers with "View All" button
  Widget _buildSectionHeader(String title, VoidCallback? onViewAll) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFFE65100).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFFE65100),
                    size: 12.sp,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLikedCardsSection(
      BuildContext context, WidgetRef ref, MyCardsScreenState state) {
    return state.likedCards.when(
      data: (likedTemplates) {
        if (likedTemplates.isEmpty) {
          return _buildEmptyState(
            'Favorites',
            'No favorite cards yet',
            'Like some cards to see them here',
            Icons.favorite_border,
            null,
          );
        }

        // Convert templates to map format for TemplateGridScreen
        final templatesForGrid = likedTemplates
            .map((template) => {
                  'templateId': template.templateId,
                  'name': template.name,
                  'category': template.category,
                  'isPremium': template.isPremium,
                  'price': template.price,
                  'frontCover': template.frontCover,
                  'ispremium': template.isPremium,
                })
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Favorites',
              likedTemplates.length > 3
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateGridScreen(
                            appBarTitle: 'Favorite',
                            templates: templatesForGrid,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 280.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    likedTemplates.length > 3 ? 3 : likedTemplates.length,
                itemBuilder: (context, index) {
                  final template = likedTemplates[index];
                  return Container(
                    width: 160.w,
                    margin: EdgeInsets.only(right: 12.w),
                    child: CardTemplate(
                      template: {
                        'templateId': template.templateId,
                        'name': template.name,
                        'category': template.category,
                        'isPremium': template.isPremium,
                        'price': template.price,
                        'frontCover': template.frontCover,
                        'ispremium': template.isPremium,
                      },
                      // Use default onTap (navigates to PreEditCardPreviewPage)
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingState('Favorites'),
      error: (error, stackTrace) => _buildErrorState(
        'Favorites',
        'Failed to load favorite cards',
        () => ref
            .read(myCardsScreenViewModelProvider.notifier)
            .refreshLikedCards(),
      ),
    );
  }

  Widget _buildPurchasedCardsSection(
      BuildContext context, WidgetRef ref, MyCardsScreenState state) {
    return state.purchasedCards.when(
      data: (purchasedCards) {
        if (purchasedCards.isEmpty) {
          return _buildEmptyState(
            'Purchased',
            'No purchased cards yet',
            'Purchase and customize cards to see them here',
            Icons.shopping_cart_outlined,
            null,
          );
        }

        // Convert cards to map format for TemplateGridScreen
        final templatesForGrid = purchasedCards
            .map((card) => {
                  'templateId': card.templateId,
                  'name': card.toName ?? 'Custom Card',
                  'category': 'Custom',
                  'isPremium': false,
                  'price': 0,
                  'frontCover': card.frontImageUrl,
                  'ispremium': false,
                })
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Purchased',
              purchasedCards.length > 3
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateGridScreen(
                            appBarTitle: 'Purchased',
                            templates: templatesForGrid,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 280.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    purchasedCards.length > 3 ? 3 : purchasedCards.length,
                itemBuilder: (context, index) {
                  final card = purchasedCards[index];
                  return Container(
                    width: 160.w,
                    margin: EdgeInsets.only(right: 12.w),
                    child: CardTemplate(
                      template: {
                        'templateId': card.templateId,
                        'name': card.toName ?? 'Custom Card',
                        'category': 'Custom',
                        'isPremium': false,
                        'price': 0,
                        'frontCover': card.frontImageUrl,
                        'ispremium': false,
                      },
                      onTap: () {
                        if (card.isShared) {
                          // Navigate to view-only screen
                          final cardData = CardData(
                            card: card,
                            toName: card.toName,
                            fromName: card.fromName,
                            greetingMessage: card.greetingMessage,
                            customImageUrl: card.customImageUrl,
                            voiceNoteUrl: card.voiceNoteUrl,
                            creditsAttached: card.creditsAttached,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CardPageView(
                                cardData: cardData,
                                showSave: false,
                              ),
                            ),
                          );
                        } else {
                          // Navigate to edit screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditCardPage(
                                template: {
                                  'templateId': card.templateId,
                                  'frontCover': card.frontImageUrl,
                                },
                                cardId: card.id,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingState('Purchased'),
      error: (error, stackTrace) => _buildErrorState(
        'Purchased',
        'Failed to load purchased cards',
        () => ref
            .read(myCardsScreenViewModelProvider.notifier)
            .refreshPurchasedCards(),
      ),
    );
  }

  Widget _buildReceivedCardsSection(
      BuildContext context, WidgetRef ref, MyCardsScreenState state) {
    return state.receivedCards.when(
      data: (receivedCards) {
        if (receivedCards.isEmpty) {
          return _buildEmptyState(
            'Received',
            'No received cards yet',
            'Cards shared with you will appear here',
            Icons.inbox_outlined,
            null,
          );
        }

        // Convert cards to map format for TemplateGridScreen
        final templatesForGrid = receivedCards
            .map((card) => {
                  'templateId': card.templateId,
                  'name': card.toName ?? 'Received Card',
                  'category': 'Received',
                  'isPremium': false,
                  'price': 0,
                  'frontCover': card.frontImageUrl,
                  'ispremium': false,
                })
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Received',
              receivedCards.length > 3
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateGridScreen(
                            appBarTitle: 'Received',
                            templates: templatesForGrid,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 280.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: receivedCards.length > 3 ? 3 : receivedCards.length,
                itemBuilder: (context, index) {
                  final card = receivedCards[index];
                  return Container(
                    width: 160.w,
                    margin: EdgeInsets.only(right: 12.w),
                    child: CardTemplate(
                      template: {
                        'templateId': card.templateId,
                        'name': card.toName ?? 'Received Card',
                        'category': 'Received',
                        'isPremium': false,
                        'price': 0,
                        'frontCover': card.frontImageUrl,
                        'ispremium': false,
                      },
                      onTap: () {
                        // Navigate to view-only screen for received cards
                        final cardData = CardData(
                          card: card,
                          toName: card.toName,
                          fromName: card.fromName,
                          greetingMessage: card.greetingMessage,
                          customImageUrl: card.customImageUrl,
                          voiceNoteUrl: card.voiceNoteUrl,
                          creditsAttached: card.creditsAttached,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CardPageView(cardData: cardData),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingState('Received'),
      error: (error, stackTrace) => _buildErrorState(
        'Received',
        'Failed to load received cards',
        () => ref
            .read(myCardsScreenViewModelProvider.notifier)
            .refreshReceivedCards(),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, String subtitle,
      IconData icon, VoidCallback? onViewAll) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, onViewAll),
        SizedBox(height: 12.h),
        Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Icon(icon, size: 32.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, null),
        SizedBox(height: 12.h),
        Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularLoadingWidget(
                  colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
                  size: 40,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Loading $title...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String title, String message, VoidCallback onRetry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, null),
        SizedBox(height: 12.h),
        Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Icon(Icons.error_outline,
                    size: 32.sp, color: Colors.red[600]),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Container(
                height: 36.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Color(0xFFE57373)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
