import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PreEdit4thPage extends StatefulWidget {
  const PreEdit4thPage({
    super.key,
    required this.audioUrl,
    required this.bgImageUrl,
  });

  final String audioUrl;
  final String bgImageUrl;

  @override
  State<PreEdit4thPage> createState() => _PreEdit4thPageState();
}

class _PreEdit4thPageState extends State<PreEdit4thPage> {
  late final AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio() async {
    if (!isPlaying) {
      await _audioPlayer.play(AssetSource(widget.audioUrl));

      setState(() {
        isPlaying = true;
      });
    } else {
      await _audioPlayer.pause();

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
            image: AssetImage(widget.bgImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            color: Colors.white.withAlpha(200), // Slight overlay for contrast
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause Button
                  Center(
                    child: Row(
                      children: [
                        IconButton(
                          iconSize: 80,
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.orange,
                          ),
                          onPressed: _playAudio,
                        ),
                        // Soundwave Animation
                        Lottie.asset(
                          width: 100,
                          "assets/animations/soundwave.json",
                          repeat: true,
                          animate: isPlaying,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  // Non-functional "Record Voice Note" Button for display
                  ElevatedButton.icon(
                    onPressed: () {
                      // This button doesn't perform any action
                    },
                    icon: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                    label: Text(
                      "Record Voice Message",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black.withAlpha(100), // Customize color
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
