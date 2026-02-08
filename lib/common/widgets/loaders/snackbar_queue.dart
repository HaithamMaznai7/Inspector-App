import 'package:flutter/foundation.dart';

class SnackbarQueue {
  static final List<_SnackJob> _queue = [];
  static bool _isShowing = false;

  static void show(
    VoidCallback show,
    {
      int duration = 3,
    }
  ) {
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
}

class _SnackJob {
  final VoidCallback show;
  final int duration;

  _SnackJob(this.show, this.duration);
}
