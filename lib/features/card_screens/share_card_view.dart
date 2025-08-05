import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lottie/lottie.dart';
import 'package:mycards/features/my_cards/presentation/providers/my_cards_screen_vm.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mycards/features/edit_screens/card_data_provider.dart';
import 'package:mycards/features/cards/data/card_repository_impl.dart';
import 'package:mycards/features/app_user/app_user_provider.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

class ShareCardView extends ConsumerStatefulWidget {
  const ShareCardView({
    super.key,
    required this.cardData,
  });

  final CardData cardData;

  @override
  ConsumerState<ShareCardView> createState() => _ShareCardViewState();
}

class _ShareCardViewState extends ConsumerState<ShareCardView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'US');
  String phoneNumber = "";
  bool _isSharing = false;
  String? _shareLink;
  String? _error;

  @override
  void initState() {
    super.initState();
    _createShareLink();
  }

  Future<void> _createShareLink() async {
    try {
      setState(() {
        _isSharing = true;
        _error = null;
      });

      final user = AppUserService.instance.currentUser;
      if (user == null) {
        throw Exception('No user available');
      }

      final cardRepository = ref.read(cardRepositoryProvider);

      if (widget.cardData.card?.id == null) {
        throw Exception('No card ID available');
      }

      // Create share link
      final shareLink = await cardRepository.createShareLink(
        widget.cardData.card!.id,
        widget.cardData.card!,
        user.userId,
      );
      await ref
          .read(myCardsScreenViewModelProvider.notifier)
          .refreshPurchasedCards();

      setState(() {
        _shareLink = shareLink;
        _isSharing = false;
      });

      AppLogger.log('Share link created: $shareLink', tag: 'ShareCardView');
    } catch (e) {
      AppLogger.logError('Error creating share link: $e', tag: 'ShareCardView');
      setState(() {
        _error = e.toString();
        _isSharing = false;
      });
    }
  }

  Future<void> _shareViaEmail() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an email address")),
      );
      return;
    }

    try {
      setState(() {
        _isSharing = true;
      });

      final user = AppUserService.instance.currentUser;
      if (user == null) {
        throw Exception('No user available');
      }

      final cardRepository = ref.read(cardRepositoryProvider);

      // Add card to receivedCards for the recipient
      await cardRepository.addToReceivedCards(
        widget.cardData.card!.id,
        emailController.text,
      );

      // Share via email (in real app, you'd integrate with email service)
      if (_shareLink != null) {
        await Share.share(
          'Check out this amazing card I made for you!\n\nView your card here: $_shareLink\n\nYou also received ${widget.cardData.creditsAttached} free credits!',
          subject: 'Digital Card from ${widget.cardData.fromName}',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Card shared successfully via email!")),
        );
      }
    } catch (e) {
      AppLogger.logError('Error sharing via email: $e', tag: 'ShareCardView');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sharing via email: $e")),
        );
      }
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<void> _shareViaPhone() async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a phone number")),
      );
      return;
    }

    try {
      setState(() {
        _isSharing = true;
      });

      final user = AppUserService.instance.currentUser;
      if (user == null) {
        throw Exception('No user available');
      }

      final cardRepository = ref.read(cardRepositoryProvider);

      // Add card to receivedCards for the recipient
      await cardRepository.addToReceivedCards(
        widget.cardData.card!.id,
        phoneNumber,
      );

      // Share via SMS (in real app, you'd integrate with SMS service)
      if (_shareLink != null) {
        await Share.share(
          'Check out this amazing card I made for you!\n\nView your card here: $_shareLink\n\nYou also received ${widget.cardData.creditsAttached} free credits!',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Card shared successfully via phone!")),
        );
      }
    } catch (e) {
      AppLogger.logError('Error sharing via phone: $e', tag: 'ShareCardView');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sharing via phone: $e")),
        );
      }
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<void> _shareViaSocialMedia() async {
    try {
      if (_shareLink != null) {
        await Share.share(
          'Check out this amazing card I made for you!\n\nView your card here: $_shareLink\n\nYou also received ${widget.cardData.creditsAttached} free credits!',
          subject: 'Digital Card from ${widget.cardData.fromName}',
          sharePositionOrigin:
              Rect.fromCircle(center: Offset(0, 0), radius: 10),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Share link not ready yet, please wait")),
        );
      }
    } catch (e) {
      AppLogger.logError('Error sharing via social media: $e',
          tag: 'ShareCardView');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Lottie.asset("assets/animations/share.json",
                      repeat: true, height: 200),
                  const Text(
                    "Share the joy!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Send this card to ${widget.cardData.toName ?? 'the recipient'} via email or phone number.\nThe recipient will also receive ${widget.cardData.creditsAttached} free credits from us to help you celebrate - Courtesy of Our Team",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(60),
                        borderRadius: BorderRadius.circular(20)),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        labelText: "Email",
                        hintText: "Enter recipient's email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text("OR")),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(60),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InternationalPhoneNumberInput(
                        initialValue: initialPhoneNumber,
                        inputDecoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                          hintText: "Phone number",
                          border: InputBorder.none,
                        ),
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        onInputChanged: (PhoneNumber number) {
                          setState(() {
                            phoneNumber = number.phoneNumber!;
                          });
                          log(phoneNumber);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _isSharing
                              ? null
                              : () {
                                  if (emailController.text.isNotEmpty) {
                                    _shareViaEmail();
                                  } else if (phoneNumber.isNotEmpty) {
                                    _shareViaPhone();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please enter an email or phone number."),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSharing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularLoadingWidget(
                                    colors: [
                                      Colors.white,
                                      Colors.white70,
                                      Colors.white54,
                                      Colors.white38
                                    ],
                                  ),
                                )
                              : const Text(
                                  "Share Card",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Or share via other social apps",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: _shareViaSocialMedia,
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Colors.redAccent,
                      size: 50,
                    ),
                  ),
                  if (_shareLink != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Share Link Generated!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _shareLink!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isSharing && _shareLink == null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularLoadingWidget(
                        colors: [
                          Colors.white,
                          Colors.white70,
                          Colors.white54,
                          Colors.white38
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Creating share link...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
