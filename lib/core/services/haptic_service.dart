import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Service for haptic feedback (vibrations)
class HapticService {
  // Light vibration
  static Future<void> lightVibration() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback not supported: $e');
    }
  }

  // Medium vibration
  static Future<void> mediumVibration() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback not supported: $e');
    }
  }

  // Heavy vibration (for important events)
  static Future<void> heavyVibration() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback not supported: $e');
    }
  }

  // Success pattern (double tap)
  static Future<void> successVibration() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback not supported: $e');
    }
  }

  // Warning vibration (triple tap)
  static Future<void> warningVibration() async {
    try {
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.lightImpact();
        if (i < 2) await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      debugPrint('Haptic feedback not supported: $e');
    }
  }
}