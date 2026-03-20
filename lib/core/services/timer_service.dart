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
    _timer?.cancel();

    _totalSeconds = durationSeconds;
    _elapsedSeconds = 0;
    _isRunning = true;
    _elapsedStreamController.add(_elapsedSeconds);
    _startTicker();
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning) return;
      _elapsedSeconds += 1;
      if (_elapsedSeconds > _totalSeconds) {
        _elapsedSeconds = _totalSeconds;
      }
      _elapsedStreamController.add(_elapsedSeconds);

      if (_elapsedSeconds >= _totalSeconds) {
        _timer?.cancel();
        _isRunning = false;
      }
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
    if (_totalSeconds <= 0) return;
    _isRunning = true;
    _startTicker();
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