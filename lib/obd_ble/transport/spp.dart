import 'dart:async';

import 'package:flutter/services.dart';

/// Lightweight description of a Bluetooth Classic device returned by the
/// native SPP plugin. `id` is the MAC address; `name` falls back to the
/// MAC if the device's name isn't readable (Android 12+ requires
/// BLUETOOTH_CONNECT to read names).
class SppDevice {
  final String id;
  final String name;

  const SppDevice({required this.id, required this.name});

  factory SppDevice.fromChannelMap(Object? raw) {
    final map = (raw as Map).cast<String, dynamic>();
    final id = map['id'] as String;
    final name = (map['name'] as String?) ?? id;
    return SppDevice(id: id, name: name);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SppDevice && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SppDevice($name, $id)';
}

/// Dart-side bridge to the native `SppPlugin` (Bluetooth Classic / SPP).
///
/// The plugin lives at:
///   android/app/src/main/kotlin/sa/fahis/fahis_inspector/bluetooth/SppPlugin.kt
///
/// This class exposes the channel contract as a thin static API. The four
/// channel names below MUST match the strings used inside `SppPlugin.kt`
/// exactly — they form the wire protocol between Dart and Kotlin.
///
/// All methods may throw `PlatformException` if the native side fails or if
/// a required runtime permission (`BLUETOOTH_CONNECT` / `BLUETOOTH_SCAN`)
/// hasn't been granted yet — callers are responsible for catching those.
class Spp {
  Spp._();

  // ── Channel contract — must match SppPlugin.kt exactly ──────────────────

  static const MethodChannel _methods = MethodChannel('spp/methods');
  static const MethodChannel _scanMethods = MethodChannel('spp/scan_methods');
  static const EventChannel _events = EventChannel('spp/events');
  static const EventChannel _scan = EventChannel('spp/scan');

  // ── Adapter / settings ──────────────────────────────────────────────────

  /// Whether the device's Bluetooth radio is currently turned on.
  static Future<bool> isEnabled() async {
    final result = await _methods.invokeMethod<bool>('isEnabled');
    return result ?? false;
  }

  /// Opens the system Bluetooth settings screen so the user can pair a new
  /// adapter. Used by the device-picker bottom sheet.
  static Future<void> openSettings() async {
    await _methods.invokeMethod<bool>('openSettings');
  }

  // ── Bonded devices ──────────────────────────────────────────────────────

  /// Returns the devices the user has already paired through Android
  /// Bluetooth settings. SPP requires bonding before connect, so this is
  /// what the picker displays.
  static Future<List<SppDevice>> bondedDevices() async {
    final raw = await _methods.invokeMethod<List<dynamic>>('bondedDevices');
    if (raw == null || raw.isEmpty) return const [];
    return raw.map(SppDevice.fromChannelMap).toList(growable: false);
  }

  // ── Connection lifecycle ────────────────────────────────────────────────

  /// Opens an RFCOMM SPP connection to [deviceId] (MAC address).
  /// Throws [PlatformException] on failure (device not paired, BT off,
  /// permission missing, socket refused by adapter, …).
  static Future<void> connect(String deviceId) async {
    await _methods.invokeMethod<bool>('connect', <String, dynamic>{
      'id': deviceId,
    });
  }

  /// Closes the current SPP socket. Safe to call when no socket is open
  /// (the native side returns successfully in that case).
  static Future<void> disconnect() async {
    await _methods.invokeMethod<bool>('disconnect');
  }

  /// Writes [data] to the SPP socket. Bytes are interpreted as US-ASCII on
  /// the native side (sufficient for ELM327 commands like `ATZ\r` / `010C\r`).
  /// If you ever need to send arbitrary binary, switch the channel argument
  /// to a `Uint8List` and update the `write` handler in `SppPlugin.kt`.
  static Future<void> write(List<int> data) async {
    final ascii = String.fromCharCodes(data);
    await _methods.invokeMethod<bool>('write', <String, dynamic>{
      'data': ascii,
    });
  }

  /// Stream of incoming byte chunks from the SPP socket. Each event is one
  /// `read()` call's worth of bytes from the native reader. ELM327 responses
  /// can span multiple chunks — callers (e.g. `Elm327CommandService`) must
  /// accumulate until the `>` prompt arrives.
  ///
  /// The native side decodes bytes as US-ASCII before sending across the
  /// channel; we re-pack them as `Uint8List` here so consumers see the same
  /// shape `flutter_bluetooth_serial`'s `connection.input!` produced. This
  /// means `ObdBleConnectionService` only changes its source for bytes —
  /// not the type it forwards downstream.
  ///
  /// The stream emits `done` when the socket closes (intentional or lost).
  static Stream<Uint8List> byteStream() {
    return _events.receiveBroadcastStream().map((event) {
      final s = event as String;
      return Uint8List.fromList(s.codeUnits);
    });
  }

  // ── Discovery ───────────────────────────────────────────────────────────

  /// Starts Bluetooth Classic discovery. Bonded devices are NOT re-emitted
  /// through this stream — call [bondedDevices] separately to list paired
  /// adapters. Returns false if the adapter rejected the request (e.g.
  /// already discovering, BT off).
  static Future<bool> startDiscovery() async {
    final result = await _scanMethods.invokeMethod<bool>('startDiscovery');
    return result ?? false;
  }

  /// Cancels the in-flight discovery cycle and unregisters the native
  /// receiver. Safe to call when no discovery is active.
  static Future<void> cancelDiscovery() async {
    await _scanMethods.invokeMethod<bool>('cancelDiscovery');
  }

  /// Triggers Android's pair-with-device dialog for [id]. Returns true if
  /// the bond process started; the eventual bonded state must be observed
  /// separately (out of scope for this plugin — the user typically returns
  /// from settings and the picker re-reads [bondedDevices]).
  static Future<bool> createBond(String id) async {
    final result = await _scanMethods.invokeMethod<bool>(
      'createBond',
      <String, dynamic>{'id': id},
    );
    return result ?? false;
  }

  /// Stream of devices reported by an active discovery scan. Each event is
  /// one newly found device. The stream stays open across scan cycles — call
  /// [startDiscovery] again to receive more events on the same listener.
  static Stream<SppDevice> discoveryStream() {
    return _scan.receiveBroadcastStream().map(SppDevice.fromChannelMap);
  }
}
