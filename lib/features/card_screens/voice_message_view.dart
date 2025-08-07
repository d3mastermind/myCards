import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VoiceMessageView extends StatefulWidget {
  const VoiceMessageView({
    super.key,
    required this.audioUrl,
    required this.bgImageUrl,
    this.isUrl = false,
  });

  final String audioUrl;
  final String bgImageUrl;
  final bool isUrl;
  @override
  State<VoiceMessageView> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageView>
    with TickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  bool isPlaying = false;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _playAudio() async {
    if (!isPlaying) {
      await _audioPlayer.play(DeviceFileSource(widget.audioUrl));
      _pulseController.repeat(reverse: true);

      setState(() {
        isPlaying = true;
      });
    } else {
      await _audioPlayer.pause();
      _pulseController.stop();
      _pulseController.reset();

      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: widget.isUrl
                ? NetworkImage(widget.bgImageUrl)
                : AssetImage(widget.bgImageUrl) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main content
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Title
                          const Text(
                            'Voice Message',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to play your personalized message',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Play button and animation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Play/Pause Button with pulse animation
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        isPlaying ? _pulseAnimation.value : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF5722),
                                            Color(0xFFFF7043),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.orange.withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        iconSize: 60,
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        onPressed: _playAudio,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(width: 24),

                              // Soundwave Animation
                              Expanded(
                                child: Lottie.asset(
                                  "assets/animations/soundwave.json",
                                  repeat: true,
                                  animate: isPlaying,
                                  height: 80,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isPlaying
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isPlaying
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPlaying
                                      ? Icons.music_note
                                      : Icons.music_off,
                                  color:
                                      isPlaying ? Colors.green : Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isPlaying ? 'Playing...' : 'Ready to play',
                                  style: TextStyle(
                                    color: isPlaying
                                        ? Colors.green
                                        : Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
