import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/features/card_screens/shared_card_viewer.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks(); // Initialize AppLinks as singleton
  StreamSubscription<Uri>? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize deep link handling with navigator key
  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _initDeepLinks();
  }

  /// Initialize deep link handling following app_links best practices
  Future<void> _initDeepLinks() async {
    AppLogger.log('Initializing deep link service...', tag: 'DeepLinkService');

    // Handle incoming links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        AppLogger.log('Incoming deep link: $uri', tag: 'DeepLinkService');
        _processDeepLink(uri);
      },
      onError: (err) {
        AppLogger.logError('Deep link stream error: $err',
            tag: 'DeepLinkService');
      },
    );

    // Handle initial link when app is launched from deep link
    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        AppLogger.log('Initial deep link: $initialLink',
            tag: 'DeepLinkService');
        // Add a small delay to ensure the app is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          _processDeepLink(initialLink);
        });
      } else {
        AppLogger.log('No initial deep link found', tag: 'DeepLinkService');
      }
    } catch (e) {
      AppLogger.logError('Failed to get initial link: $e',
          tag: 'DeepLinkService');
    }
  }

  /// Process the deep link and navigate accordingly
  void _processDeepLink(Uri uri) {
    if (_navigatorKey?.currentState == null) {
      AppLogger.logError('Navigator not available for deep link navigation',
          tag: 'DeepLinkService');
      return;
    }

    AppLogger.log('Processing deep link URI: ${uri.toString()}',
        tag: 'DeepLinkService');

    String? shareLinkId;

    // Handle custom scheme: mycards://card/view?id={shareLinkId}
    if (uri.scheme == 'mycards' && uri.host == 'card' && uri.path == '/view') {
      shareLinkId = uri.queryParameters['id'];
    }
    // Handle Firebase hosting URLs: https://mycards-c7f33.web.app/card?id={shareLinkId}
    else if (uri.scheme == 'https' &&
        (uri.host == 'mycards-c7f33.web.app' ||
            uri.host == 'mycards-c7f33.firebaseapp.com') &&
        uri.path == '/card') {
      shareLinkId = uri.queryParameters['id'];
    }
    // Handle Firebase hosting URLs: https://mycards-c7f33.web.app/card/{shareLinkId} (alternative format)
    else if (uri.scheme == 'https' &&
        (uri.host == 'mycards-c7f33.web.app' ||
            uri.host == 'mycards-c7f33.firebaseapp.com') &&
        uri.pathSegments.length == 2 &&
        uri.pathSegments[0] == 'card') {
      shareLinkId = uri.pathSegments[1];
    }

    if (shareLinkId != null && shareLinkId.isNotEmpty) {
      AppLogger.log('Extracted shareLinkId: $shareLinkId',
          tag: 'DeepLinkService');
      _navigateToSharedCard(shareLinkId);
    } else {
      AppLogger.logError('No card ID found in deep link: ${uri.toString()}',
          tag: 'DeepLinkService');
      _showErrorMessage('Invalid card link');
    }
  }

  /// Navigate to shared card viewer
  void _navigateToSharedCard(String shareLinkId) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      AppLogger.logError('Navigator state not available',
          tag: 'DeepLinkService');
      return;
    }

    AppLogger.log('Navigating to shared card: $shareLinkId',
        tag: 'DeepLinkService');

    navigator.push(
      MaterialPageRoute(
        builder: (context) => SharedCardViewer(shareLinkId: shareLinkId),
        fullscreenDialog: true, // Better UX for deep link navigation
      ),
    );
  }

  /// Show error message to user
  void _showErrorMessage(String message) {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      AppLogger.logError('Context not available for error message',
          tag: 'DeepLinkService');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Generate web-compatible share link for a card
  static String generateCardShareLink(String shareLinkId) {
    return 'https://mycards.app/card?id=$shareLinkId';
  }

  /// Generate custom scheme deep link for a card (for internal use)
  static String generateCardDeepLink(String shareLinkId) {
    return 'mycards://card/view?id=$shareLinkId';
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _navigatorKey = null;
    AppLogger.log('Deep link service disposed', tag: 'DeepLinkService');
  }
}
