import 'package:flutter/foundation.dart';

// WHAT: A queue that serializes snackbar display to prevent overlapping.
// WHY: Without a queue, multiple simultaneous errors (e.g., 5 parallel API
//      failures when offline) would try to show 5 snackbars at once, causing
//      overlay conflicts and UI flooding.
// HOW: Jobs are added to a FIFO queue. Only one snackbar shows at a time.
//      After each snackbar's duration + buffer, the next one is processed.
// EDGE CASES:
//   - Queue overflow: capped at _maxQueueSize to prevent memory issues
//   - Rapid duplicate errors: throttled to prevent identical snackbar spam
class SnackbarQueue {
  static final List<_SnackJob> _queue = [];
  static bool _isShowing = false;

  // WHAT: Maximum number of snackbars that can be queued at once.
  // WHY: When offline, many API calls fail simultaneously. Without a cap,
  //      the queue could grow unbounded and show stale errors minutes later.
  // HOW: New jobs are dropped when the queue is full.
  static const int _maxQueueSize = 3;

  // WHAT: Timestamp of the last queued snackbar to throttle duplicates.
  // WHY: Multiple repositories call e.notify() within milliseconds of each
  //      other when offline, producing identical "No Connection" snackbars.
  // HOW: If a new job arrives within _throttleDuration of the last one,
  //      it is dropped (since it's likely a duplicate error).
  static DateTime? _lastAddedTime;
  static const Duration _throttleDuration = Duration(milliseconds: 500);

  static void show(
    VoidCallback show,
    {
      int duration = 3,
    }
  ) {
    // WHAT: Drop new jobs if queue is already full.
    // WHY: Prevents queue from growing unbounded during mass failures.
    if (_queue.length >= _maxQueueSize) return;

    // WHAT: Throttle rapid-fire snackbar requests.
    // WHY: When 5 API calls fail at once, we don't need 5 identical
    //      "No Connection" snackbars. One is enough to inform the user.
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

  // WHAT: Clear all pending snackbar jobs.
  // WHY: Useful when navigating away from a screen — stale error
  //      snackbars from the previous screen should not appear.
  // RELATED: Could be called from controller.onClose() if needed.
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
