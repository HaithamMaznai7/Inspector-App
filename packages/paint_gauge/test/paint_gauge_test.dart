import 'package:flutter_test/flutter_test.dart';
import 'package:paint_gauge/paint_gauge.dart';
import 'package:paint_gauge/paint_gauge_platform_interface.dart';
import 'package:paint_gauge/paint_gauge_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPaintGaugePlatform
    with MockPlatformInterfaceMixin
    implements PaintGaugePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PaintGaugePlatform initialPlatform = PaintGaugePlatform.instance;

  test('$MethodChannelPaintGauge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPaintGauge>());
  });

  test('getPlatformVersion', () async {
    PaintGauge paintGaugePlugin = PaintGauge();
    MockPaintGaugePlatform fakePlatform = MockPaintGaugePlatform();
    PaintGaugePlatform.instance = fakePlatform;

    expect(await paintGaugePlugin.getPlatformVersion(), '42');
  });
}
