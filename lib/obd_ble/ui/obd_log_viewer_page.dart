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

/// Active filter for the log viewer.
enum _LogFilter { all, recv, err }

class _ObdLogViewerPageState extends State<ObdLogViewerPage> {
  final ScrollController _scroll = ScrollController();
  bool _autoScroll = true;
  _LogFilter _filter = _LogFilter.all;
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

  List<ObdLogEntry> _applyFilter(List<ObdLogEntry> all) {
    switch (_filter) {
      case _LogFilter.recv:
        return all.where((e) => e.level == ObdLogLevel.recv).toList();
      case _LogFilter.err:
        return all
            .where((e) =>
                e.level == ObdLogLevel.error || e.level == ObdLogLevel.warn)
            .toList();
      case _LogFilter.all:
        return all;
    }
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
        title: Obx(() {
          final count = ObdLogger.entries.length;
          return Text(
            'OBD Log ($count)',
            style: const TextStyle(fontWeight: FontWeight.w700),
          );
        }),
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
        child: Column(
          children: [
            _FilterBar(
              selected: _filter,
              onChanged: (f) => setState(() {
                _filter = f;
                if (_autoScroll && _scroll.hasClients) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scroll.hasClients) {
                      _scroll.jumpTo(_scroll.position.maxScrollExtent);
                    }
                  });
                }
              }),
            ),
            Expanded(
              child: Obx(() {
                final entries = _applyFilter(ObdLogger.entries);
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
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final _LogFilter selected;
  final ValueChanged<_LogFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _chip('All', _LogFilter.all, const Color(0xFF7AC0FF)),
          const SizedBox(width: 6),
          _chip('RECV', _LogFilter.recv, const Color(0xFF7EE787)),
          const SizedBox(width: 6),
          _chip('ERR', _LogFilter.err, const Color(0xFFFF7E7E)),
        ],
      ),
    );
  }

  Widget _chip(String label, _LogFilter filter, Color color) {
    final isActive = selected == filter;
    return GestureDetector(
      onTap: () => onChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : color.withValues(alpha: 0.5),
            fontFamily: 'Courier',
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
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
    final isRecv = entry.level == ObdLogLevel.recv;
    final isErr = entry.level == ObdLogLevel.error || entry.level == ObdLogLevel.warn;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isRecv
            ? const Color(0xFF7EE787).withValues(alpha: 0.07)
            : isErr
                ? const Color(0xFFFF7E7E).withValues(alpha: 0.05)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
              style: TextStyle(
                color: isRecv ? const Color(0xFFB5F0BC) : Colors.white,
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
