import 'package:flutter/material.dart';
import 'dart:async';

// Detects when user leaves the app (distraction)
class DistractionService {
  final StreamController<int> _distractionStream =
      StreamController<int>.broadcast();
  AppLifecycleListener? _lifecycleListener;
  bool _wasInFocus = false;
  int _distractionCount = 0;

  Stream<int> get distractionStream => _distractionStream.stream;

  // Start monitoring app lifecycle
  void startMonitoring() {
    _wasInFocus = true;
    _distractionCount = 0;

    _lifecycleListener = AppLifecycleListener(
      onShow: _onAppShow,
      onHide: _onAppHide,
      onResume: _onAppResume,
      onPause: _onAppPause,
      onDetach: _onAppDetach,
      onInactive: _onAppInactive,
    );

    debugPrint('Distraction monitoring started');
  }

  // App became visible (from background)
  void _onAppShow() {
    debugPrint('App shown (from background)');
  }

  // App hidden (user minimized)
  void _onAppHide() {
    debugPrint(' App hidden (minimized)');
    if (_wasInFocus) {
      _recordDistraction();
    }
  }

  // App resumed from paused state
  void _onAppResume() {
    debugPrint(' App resumed');
    _wasInFocus = true;
  }

  // App paused (backgrounded)
  void _onAppPause() {
    debugPrint(' App paused');
    _wasInFocus = false;
  }

  // App about to detach (closing)
  void _onAppDetach() {
    debugPrint(' App detaching');
  }

  // App became inactive
  void _onAppInactive() {
    debugPrint('App inactive');
    if (_wasInFocus) {
      _recordDistraction();
    }
  }

  // Record a distraction event
  void _recordDistraction() {
    _distractionCount++;
    debugPrint(' Distraction detected! Count: $_distractionCount');
    _distractionStream.add(_distractionCount);
  }

  // Get current distraction count
  int get distractionCount => _distractionCount;

  // Reset distraction count
  void reset() {
    _distractionCount = 0;
  }

  // Stop monitoring
  void stopMonitoring() {
    _lifecycleListener?.dispose();
    debugPrint(' Distraction monitoring stopped');
  }

  // Cleanup
  void dispose() {
    stopMonitoring();
    _distractionStream.close();
  }
}