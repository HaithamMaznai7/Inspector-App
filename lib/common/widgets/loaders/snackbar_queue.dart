import 'package:flutter/foundation.dart';

class SnackbarQueue {
  static final List<_SnackJob> _queue = [];
  static bool _isShowing = false;

  static const int _maxQueueSize = 3;

  static DateTime? _lastAddedTime;
  static const Duration _throttleDuration = Duration(milliseconds: 500);

  static void show(VoidCallback show, {int duration = 3}) {
    if (_queue.length >= _maxQueueSize) return;

    final now = DateTime.now();
    if (_lastAddedTime != null &&
        now.difference(_lastAddedTime!) < _throttleDuration) {
      return;
    }
    _lastAddedTime = now;

    _queue.add(_SnackJob(show, duration));
    _process();
  }

  static void _process() {
    if (_isShowing || _queue.isEmpty) return;

    _isShowing = true;
    final job = _queue.removeAt(0);

    job.show();

    Future.delayed(Duration(seconds: job.duration + 1), () {
      _isShowing = false;
      _process();
    });
  }

  static void clear() {
    _queue.clear();
    _isShowing = false;
  }
}

class _SnackJob {
  final VoidCallback show;
  final int duration;

  _SnackJob(this.show, this.duration);
}
