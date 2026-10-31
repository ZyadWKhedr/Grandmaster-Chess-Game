import 'dart:async';

/// Pure domain/service layer timer manager for chess clock control.
class GameTimerService {
  Timer? _timer;

  void start({
    required void Function() onTick,
  }) {
    cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => onTick());
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}
