import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:get/get.dart';

/// Localized display labels for [CarPart] panel names.
///
/// Kept as an extension (not on the enum itself) because [CarPart] lives
/// in the BLE protocol layer and should not depend on localization.
extension CarPartLabel on CarPart {
  String get localizedLabel {
    switch (this) {
      case CarPart.frontHatch:
        return PaintGaugePage.panelHood.tr;
      case CarPart.roof:
        return PaintGaugePage.panelRoof.tr;
      case CarPart.trunkCover:
        return PaintGaugePage.panelTrunk.tr;
      case CarPart.flWing:
        return PaintGaugePage.panelLeftFrontFender.tr;
      case CarPart.lAColumn:
        return PaintGaugePage.panelLeftAPillar.tr;
      case CarPart.flDoor:
        return PaintGaugePage.panelLeftFrontDoor.tr;
      case CarPart.lBColumn:
        return PaintGaugePage.panelLeftBPillar.tr;
      case CarPart.blDoor:
        return PaintGaugePage.panelLeftRearDoor.tr;
      case CarPart.lCColumn:
        return PaintGaugePage.panelLeftCPillar.tr;
      case CarPart.blWing:
        return PaintGaugePage.panelLeftRearFender.tr;
      case CarPart.lDColumn:
        return PaintGaugePage.panelLeftDPillar.tr;
      case CarPart.rDColumn:
        return PaintGaugePage.panelRightDPillar.tr;
      case CarPart.brWing:
        return PaintGaugePage.panelRightRearFender.tr;
      case CarPart.rCColumn:
        return PaintGaugePage.panelRightCPillar.tr;
      case CarPart.brDoor:
        return PaintGaugePage.panelRightRearDoor.tr;
      case CarPart.rBColumn:
        return PaintGaugePage.panelRightBPillar.tr;
      case CarPart.frDoor:
        return PaintGaugePage.panelRightFrontDoor.tr;
      case CarPart.rAColumn:
        return PaintGaugePage.panelRightAPillar.tr;
      case CarPart.frWing:
        return PaintGaugePage.panelRightFrontFender.tr;
    }
  }
}
