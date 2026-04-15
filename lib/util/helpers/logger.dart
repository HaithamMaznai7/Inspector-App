import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._(); // pure static — not instantiable

  static String _ts() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
  }

  static void _emit(String level, String tag, String message, dynamic data) {
    // ignore: avoid_print
    print('[${_ts()}] [$level] [$tag] $message');
    if (data != null) {
      // ignore: avoid_print
      print('  ↳ $data');
    }
  }

  /// General-purpose log. Use when none of the other levels fit.
  static void log(String tag, String message, [dynamic data]) {
    if (!kDebugMode) return;
    _emit('LOG', tag, message, data);
  }

  /// Informational milestones (service init, auth state changes, etc.).
  static void info(String tag, String message, [dynamic data]) {
    if (!kDebugMode) return;
    _emit('INFO', tag, message, data);
  }

  /// Non-fatal issues worth investigating (unexpected but recoverable state).
  static void warn(String tag, String message, [dynamic data]) {
    if (!kDebugMode) return;
    _emit('WARN', tag, message, data);
  }

  /// Errors and exceptions. Pass the caught object as [data].
  static void error(String tag, String message, [dynamic data]) {
    if (!kDebugMode) return;
    _emit('ERROR', tag, message, data);
  }

  /// Step-by-step flow tracing. Use to follow a single operation end-to-end.
  static void trace(String tag, String message, [dynamic data]) {
    if (!kDebugMode) return;
    _emit('TRACE', tag, message, data);
  }
}
