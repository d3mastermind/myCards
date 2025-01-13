import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VoiceMessageView extends StatefulWidget {
  const VoiceMessageView({
    super.key,
    required this.audioUrl,
    required this.bgImageUrl,
  });

  final String audioUrl;
  final String bgImageUrl;

  @override
  State<VoiceMessageView> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageView> {
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
              child: Row(
                //alignment: Alignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause Button
                  IconButton(
                    iconSize: 80,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.blue,
                    ),
                    onPressed: _playAudio,
                  ),
                  // Soundwave Animation
                  Lottie.asset(
                    "assets/animations/soundwave.json",
                    repeat: true,
                    animate: isPlaying,
                    //width: 100,
                    //height: 100,
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
