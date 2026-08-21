import 'dart:async';

class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 350)});

  final Duration delay;
  Timer? _timer;

  bool get isActive => _timer?.isActive == true;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void runImmediately(void Function() action) {
    cancel();
    action();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
