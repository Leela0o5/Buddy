import 'dart:async';

// Service that manages a focus session timer
// Emits elapsed time every 100ms
class TimerService {
  late StreamController<int> _elapsedStreamController;
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;

  TimerService() {
    _elapsedStreamController = StreamController<int>.broadcast();
  }

  /// Start the timer
  void start(int durationSeconds) {
    if (_isRunning) return;

    _totalSeconds = durationSeconds;
    _elapsedSeconds = 0;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _elapsedSeconds += 1; // Increment by 1 sec every 100ms
      if (_elapsedSeconds > _totalSeconds) {
        _elapsedSeconds = _totalSeconds;
      }
      _elapsedStreamController.add(_elapsedSeconds);
    });
  }

  // Pause the timer
  void pause() {
    _timer?.cancel();
    _isRunning = false;
  }

  // Resume the timer
  void resume() {
    if (_isRunning) return;
    start(_totalSeconds - _elapsedSeconds);
  }

  // Stop and reset the timer
  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _elapsedSeconds = 0;
    _totalSeconds = 0;
  }

  // Get time remaining (in sec)
  int getRemainingSeconds() => _totalSeconds - _elapsedSeconds;

  // Get elapsed time (in sec)
  int getElapsedSeconds() => _elapsedSeconds;

  // Check if timer is running
  bool get isRunning => _isRunning;

  // Stream of elapsed sec
  Stream<int> get elapsedStream => _elapsedStreamController.stream;

  // Cleanup
  void dispose() {
    _timer?.cancel();
    _elapsedStreamController.close();
  }
}