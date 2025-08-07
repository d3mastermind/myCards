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
import 'package:flutter/services.dart';
import 'package:mycards/screens/bottom_navbar_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _createShareLink();
  }

  Future<void> _createShareLink() async {
    try {
      setState(() {
        _isSharing = true;
      });

      final user = AppUserService.instance.currentUser;
      if (user == null) {
        throw Exception('No user available');
      }

      final cardRepository = ref.read(cardRepositoryProvider);

      if (widget.cardData.card?.id == null) {
        throw Exception('No card ID available');
      }

      AppLogger.log(
          'Creating share link for card ID: ${widget.cardData.card!.id}',
          tag: 'ShareCardView');
      AppLogger.log(
          'Card data before sharing - toName: ${widget.cardData.toName}, fromName: ${widget.cardData.fromName}, greeting: ${widget.cardData.greetingMessage}',
          tag: 'ShareCardView');

      // Create share link - the method now fetches latest data from purchasedCards internally
      final shareLink = await cardRepository.createShareLink(
        widget.cardData.card!.id,
        widget.cardData
            .card!, // This parameter is now less important since we fetch from DB
        user.userId,
      );

      // Refresh the cards list to reflect the updated share status
      await ref
          .read(myCardsScreenViewModelProvider.notifier)
          .refreshPurchasedCards();

      setState(() {
        _shareLink = shareLink;
        _isSharing = false;
      });

      AppLogger.log('Share link created successfully: $shareLink',
          tag: 'ShareCardView');
    } catch (e) {
      AppLogger.logError('Error creating share link: $e', tag: 'ShareCardView');
      setState(() {
        _isSharing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating share link: $e")),
        );
      }
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

      // Update the sharedCards collection with recipient email
      if (_shareLink != null) {
        final shareLinkId =
            _shareLink!.split('id=')[1]; // Extract share link ID from URL

        await _updateSharedCardRecipient(
            shareLinkId, emailController.text, null);

        AppLogger.log(
            'Updated shared card with recipient email: ${emailController.text}',
            tag: 'ShareCardView');

        // Open email app with pre-filled content
        final emailSubject = Uri.encodeComponent(
            'Digital Card from ${widget.cardData.fromName ?? "Your Friend"}');
        final emailBody = Uri.encodeComponent('Hi there!\n\n'
            'I made a special greeting card for you! Click the link below to view it:\n\n'
            '$_shareLink\n\n'
            'Hope you enjoy it!\n\n'
            'Best regards,\n'
            '${widget.cardData.fromName ?? "Your Friend"}');

        final emailUrl =
            'mailto:${emailController.text}?subject=$emailSubject&body=$emailBody';

        // Try to open email app
        final Uri emailUri = Uri.parse(emailUrl);
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          // Fallback to share dialog
          await Share.share(
            'Hi there!\n\nI made a special greeting card for you! View it here: $_shareLink\n\nBest regards \n${widget.cardData.fromName ?? "Your Friend"}',
            subject: 'Digital Card from ${widget.cardData.fromName}',
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening email app...")),
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

      // Update the sharedCards collection with recipient phone
      if (_shareLink != null) {
        final shareLinkId =
            _shareLink!.split('id=')[1]; // Extract share link ID from URL

        await _updateSharedCardRecipient(shareLinkId, null, phoneNumber);

        AppLogger.log('Updated shared card with recipient phone: $phoneNumber',
            tag: 'ShareCardView');

        // Create SMS message content
        final smsMessage = 'Hi! I made a special greeting card for you! '
            'View it here: $_shareLink';

        // Try to open messaging app with pre-filled content
        final smsUrl =
            'sms:$phoneNumber?body=${Uri.encodeComponent(smsMessage)}';
        final Uri smsUri = Uri.parse(smsUrl);

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        } else {
          // Fallback to share dialog
          await Share.share(smsMessage);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening messaging app...")),
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
          'Check out this amazing card I made for you!\n\nView your card here: $_shareLink',
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

  /// Update recipient details in sharedCards collection
  Future<void> _updateSharedCardRecipient(
      String shareLinkId, String? email, String? phone) async {
    try {
      final updates = <String, dynamic>{};

      if (email != null) {
        updates['receiverEmail'] = email;
        updates['receiverId'] = email; // Use email as receiver ID for now
      }

      if (phone != null) {
        updates['receiverPhone'] = phone;
        updates['receiverId'] = phone; // Use phone as receiver ID for now
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('sharedCards')
          .doc(shareLinkId)
          .update(updates);

      AppLogger.log('Updated shared card recipient details: $updates',
          tag: 'ShareCardView');
    } catch (e) {
      AppLogger.logError('Error updating shared card recipient: $e',
          tag: 'ShareCardView');
      throw Exception('Failed to update recipient details: $e');
    }
  }

  void _goToHomeAndClearStack() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ScreenController()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _goToHomeAndClearStack();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Gradient Header with Icon
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, right: 8),
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 28),
                              onPressed: _goToHomeAndClearStack,
                              tooltip: 'Close',
                            ),
                          ),
                        ),
                        Lottie.asset(
                          "assets/animations/share.json",
                          repeat: true,
                          height: 120,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Share the joy!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Send this card to ${widget.cardData.toName ?? 'the recipient'} via email or phone number.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Section: Share via Email
                            const Text(
                              "Share via Email",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Email",
                                hintText: "Enter recipient's email",
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.orangeAccent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                      color: Colors.orange, width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                    child:
                                        Divider(color: Colors.grey.shade300)),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text("OR",
                                      style: TextStyle(color: Colors.black54)),
                                ),
                                Expanded(
                                    child:
                                        Divider(color: Colors.grey.shade300)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Section: Share via Phone
                            const Text(
                              "Share via Phone",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color:
                                        Colors.orangeAccent.withOpacity(0.3)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: InternationalPhoneNumberInput(
                                  initialValue: initialPhoneNumber,
                                  inputDecoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 15),
                                    hintText: "Phone number",
                                    border: InputBorder.none,
                                  ),
                                  selectorConfig: const SelectorConfig(
                                    selectorType:
                                        PhoneInputSelectorType.BOTTOM_SHEET,
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
                            // Share Card Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isSharing
                                    ? null
                                    : () {
                                        if (emailController.text.isNotEmpty) {
                                          _shareViaEmail();
                                        } else if (phoneNumber.isNotEmpty) {
                                          _shareViaPhone();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Please enter an email or phone number."),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5722),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                icon: _isSharing
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
                                    : const Icon(Icons.send,
                                        color: Colors.white),
                                label: const Text(
                                  "Share Card",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Section: Share via Social Apps
                            const Text(
                              "Or share via other social apps",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: IconButton(
                                onPressed: _shareViaSocialMedia,
                                icon: const Icon(
                                  Icons.share_outlined,
                                  color: Colors.orange,
                                  size: 36,
                                ),
                                splashRadius: 28,
                              ),
                            ),
                            if (_shareLink != null) ...[
                              const SizedBox(height: 24),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.green.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.green, size: 22),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Share Link Generated!",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            _shareLink!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _copied ? Icons.check : Icons.copy,
                                            color: _copied
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          tooltip: _copied ? 'Copied!' : 'Copy',
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: _shareLink!));
                                            setState(() {
                                              _copied = true;
                                            });
                                            Future.delayed(
                                                const Duration(seconds: 2), () {
                                              if (mounted) {
                                                setState(() {
                                                  _copied = false;
                                                });
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
                        Lottie.asset(
                          "assets/animations/shareletter.json",
                          height: 120,
                          repeat: true,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Creating share link...",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
