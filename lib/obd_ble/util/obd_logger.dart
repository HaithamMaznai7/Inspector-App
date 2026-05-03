import 'package:get/get.dart';

/// Severity / kind of an [ObdLogEntry] — drives the colour + label in the
/// in-app viewer. Use [send] for outgoing bytes, [recv] for incoming bytes,
/// [info] for lifecycle events, [warn] for recoverable hiccups, [error] for
/// thrown exceptions.
enum ObdLogLevel { info, send, recv, warn, error }

/// One line in the in-app OBD log. Captures wall-clock time so the viewer can
/// render a stable HH:mm:ss.SSS timestamp regardless of when it's opened.
class ObdLogEntry {
  final DateTime ts;
  final ObdLogLevel level;
  final String message;

  const ObdLogEntry({
    required this.ts,
    required this.level,
    required this.message,
  });
}

/// Always-on, UI-visible logger for the OBD subsystem.
///
/// Unlike [AppLogger] this one **bypasses `kDebugMode`** — the entries are
/// pushed into a reactive `RxList` so the [ObdLogViewerPage] can render a
/// live tail of the connection on a phone in the field, including release
/// builds. Capped at [_maxEntries] so a long session doesn't grow unbounded.
///
/// Temporary instrumentation: this whole file plus the log-viewer page and
/// the trailing icon on the OBD card can be deleted once the in-field
/// debugging session is over. Nothing in the production OBD flow depends on
/// it.
class ObdLogger {
  ObdLogger._();

  static const int _maxEntries = 1000;

  /// Reactive log buffer. Watch with `Obx` / `GetBuilder` to render a tail.
  static final RxList<ObdLogEntry> entries = <ObdLogEntry>[].obs;

  static void log(String message, {ObdLogLevel level = ObdLogLevel.info}) {
    final entry = ObdLogEntry(
      ts: DateTime.now(),
      level: level,
      message: message,
    );
    entries.add(entry);
    if (entries.length > _maxEntries) {
      entries.removeRange(0, entries.length - _maxEntries);
    }
  }

  static void info(String message) => log(message, level: ObdLogLevel.info);
  static void send(String message) => log(message, level: ObdLogLevel.send);
  static void recv(String message) => log(message, level: ObdLogLevel.recv);
  static void warn(String message) => log(message, level: ObdLogLevel.warn);
  static void error(String message) => log(message, level: ObdLogLevel.error);

  static void clear() => entries.clear();
}
