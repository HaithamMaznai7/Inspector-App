import 'package:get/get.dart';

enum CarPart {
  frontHatch(0x8010, 'Hood'),
  flWing(0x0010, 'Left Front Fender'),
  lAColumn(0x0031, 'Left A-pillar'),
  flDoor(0x0020, 'Left Front Door'),
  lBColumn(0x0832, 'Left B-pillar'),
  blDoor(0x0F20, 'Left Rear Door'),
  lCColumn(0x0F33, 'Left C-pillar'),
  blWing(0x0F10, 'Left Rear Fender'),
  lDColumn(0x0F34, 'Left D-pillar'),
  trunkCover(0x8F10, 'Trunk Cover'),
  rDColumn(0xFF34, 'Right D-pillar'),
  brWing(0xFF10, 'Right Rear Fender'),
  rCColumn(0xFF33, 'Right C-pillar'),
  brDoor(0xFF20, 'Right Rear Door'),
  rBColumn(0xF832, 'Right B-pillar'),
  frDoor(0xF020, 'Right Front Door'),
  rAColumn(0xF031, 'Right A-pillar'),
  frWing(0xF010, 'Right Front Fender'),
  roof(0x8810, 'Roof');

  const CarPart(this.value, this.label);
  final int value;
  final String label;

  get getLabel => label.tr;

  static CarPart? fromValue(int value) {
    try {
      return CarPart.values.firstWhere((part) => part.value == value);
    } catch (_) {
      return null;
    }
  }
}
