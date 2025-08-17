import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

class SoundService {
  SoundService._internal();
  static final SoundService _instance = SoundService._internal();
  static SoundService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await _player.setReleaseMode(ReleaseMode.loop);
    _isInitialized = true;
  }

  Future<void> playAlarm(String assetPath) async {
    await _ensureInitialized();
    // assetPath should include the `assets/` prefix as declared in pubspec
    await _player.stop();
    try {
      // Try direct asset source first
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Fallback: load as bytes if some platforms require it
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      await _player.play(BytesSource(bytes));
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}


