import 'package:fahis_inspector/obd_ble/util/obd_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Full-screen tail of the [ObdLogger] entries — for in-field debugging on a
/// real phone. Auto-scrolls to the newest line; pause-autoscroll lets the
/// inspector inspect older entries without being yanked back to the bottom
/// every time a new RX chunk arrives. Copy-all dumps a plain-text transcript
/// to the clipboard so a session can be shared via chat or email.
///
/// Temporary debug surface — remove together with [ObdLogger] once the
/// in-field session is done.
class ObdLogViewerPage extends StatefulWidget {
  const ObdLogViewerPage({super.key});

  @override
  State<ObdLogViewerPage> createState() => _ObdLogViewerPageState();
}

class _ObdLogViewerPageState extends State<ObdLogViewerPage> {
  final ScrollController _scroll = ScrollController();
  bool _autoScroll = true;
  Worker? _appendWorker;

  @override
  void initState() {
    super.initState();
    _appendWorker = ever<List<ObdLogEntry>>(ObdLogger.entries, (_) {
      if (!_autoScroll) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scroll.hasClients) return;
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _appendWorker?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _copyAll() async {
    final entries = ObdLogger.entries.toList(growable: false);
    final buf = StringBuffer();
    for (final e in entries) {
      buf.writeln('[${_fmtTs(e.ts)}] [${_levelLabel(e.level)}] ${e.message}');
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${entries.length} log lines'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clear() {
    ObdLogger.clear();
    if (!mounted) return;
    setState(() {});
  }

  void _toggleAutoScroll() {
    setState(() => _autoScroll = !_autoScroll);
    if (_autoScroll && _scroll.hasClients) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1116),
        foregroundColor: Colors.white,
        title: const Text(
          'OBD Log',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: _autoScroll ? 'Pause auto-scroll' : 'Resume auto-scroll',
            onPressed: _toggleAutoScroll,
            icon: Icon(_autoScroll ? Iconsax.pause : Iconsax.play),
          ),
          IconButton(
            tooltip: 'Copy all',
            onPressed: _copyAll,
            icon: const Icon(Iconsax.copy),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: _clear,
            icon: const Icon(Iconsax.trash),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final entries = ObdLogger.entries;
          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'No OBD events yet.\nConnect to an adapter to see live traffic.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return Scrollbar(
            controller: _scroll,
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              itemCount: entries.length,
              itemBuilder: (_, i) => _LogRow(entry: entries[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final ObdLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(entry.level);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fmtTs(entry.ts),
            style: const TextStyle(
              color: Colors.white38,
              fontFamily: 'Courier',
              fontFeatures: [FontFeature.tabularFigures()],
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Text(
              _levelLabel(entry.level),
              style: TextStyle(
                color: color,
                fontFamily: 'Courier',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SelectableText(
              entry.message,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtTs(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');
  return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.${three(t.millisecond)}';
}

String _levelLabel(ObdLogLevel l) {
  switch (l) {
    case ObdLogLevel.info:
      return 'INFO';
    case ObdLogLevel.send:
      return 'SEND';
    case ObdLogLevel.recv:
      return 'RECV';
    case ObdLogLevel.warn:
      return 'WARN';
    case ObdLogLevel.error:
      return 'ERR ';
  }
}

Color _levelColor(ObdLogLevel l) {
  switch (l) {
    case ObdLogLevel.info:
      return const Color(0xFF7AC0FF);
    case ObdLogLevel.send:
      return const Color(0xFFFFB454);
    case ObdLogLevel.recv:
      return const Color(0xFF7EE787);
    case ObdLogLevel.warn:
      return const Color(0xFFFFD86E);
    case ObdLogLevel.error:
      return const Color(0xFFFF7E7E);
  }
}
