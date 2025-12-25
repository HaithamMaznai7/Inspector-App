package com.paintguage.paint_gauge

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/**
 * This plugin now uses flutter_blue_plus for all Bluetooth functionality.
 * Native method channel implementation has been removed.
 */
class PaintGaugePlugin : FlutterPlugin {

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}