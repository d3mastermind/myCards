import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mycards/providers/card_data_provider.dart';

class VoiceRecordingScreen extends ConsumerStatefulWidget {
  const VoiceRecordingScreen({super.key});

  @override
  ConsumerState<VoiceRecordingScreen> createState() =>
      _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends ConsumerState<VoiceRecordingScreen>
    with AutomaticKeepAliveClientMixin {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasPermission = false;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final status = await Permission.microphone.request();
      _hasPermission = status.isGranted;

      if (_hasPermission) {
        await _initializeRecorder();
        await _initializePlayer();
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      log('Setup error: $e');
      if (mounted) {
        _showError('Failed to initialize audio components');
      }
    }
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  Future<void> _initializePlayer() async {
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
  }

  Future<void> _startRecording() async {
    if (!_hasPermission || !_isInitialized) {
      _showError(
          'Microphone permission not granted or recorder not initialized');
      return;
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/recording_$timestamp.aac';

    try {
      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      log('Recording error: $e');
      _showError('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final filePath = await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          ref.read(cardEditingProvider.notifier).recordVoiceMessage(filePath);
          _showSuccess('Recording saved successfully');
        }
      }
    } catch (e) {
      log('Stop recording error: $e');
      _showError('Failed to stop recording');
    }
  }

  Future<void> _playRecording(String path) async {
    try {
      await _player!.startPlayer(
        fromURI: path,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      log('Playback error: $e');
      _showError('Failed to play recording');
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _player!.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      log('Stop playback error: $e');
      _showError('Failed to stop playback');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  Widget _buildRecordingControls() {
    return Column(
      children: [
        const Text(
          'Record your voice message',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRecording ? Colors.red : Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingRecording(String recordingPath) {
    return Column(
      children: [
        const Text(
          'Voice Message',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isPlaying
                          ? _stopPlayback
                          : () => _playRecording(recordingPath),
                      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Text(
                        _isPlaying ? 'Stop' : 'Play Recording',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPlaying ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Record New Message'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final cardData = ref.watch(cardEditingProvider);

    if (!_hasPermission) {
      return const Center(
        child: Text(
          'Microphone permission is required for voice recording.',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: _isRecording
                ? _buildRecordingControls()
                : cardData.voiceRecording != null
                    ? _buildExistingRecording(cardData.voiceRecording!)
                    : _buildRecordingControls(),
          ),
        ),
      ],
    );
  }
}
