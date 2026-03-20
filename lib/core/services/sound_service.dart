import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Lightweight app sound feedback service.
class SoundService {
  static Future<void> click() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Sound feedback not supported: $e');
    }
  }

  static Future<void> alert() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('Sound feedback not supported: $e');
    }
  }
}