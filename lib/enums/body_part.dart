import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:get/get.dart';

enum BodyPart {
  right,
  left,
  front,
  back,
  top,
  interior;

  static BodyPart set(String bodyPart) {
    switch (bodyPart) {
      case 'Top':
        return BodyPart.top;
      case 'Left':
        return BodyPart.left;
      case 'Right':
        return BodyPart.right;
      case 'Front':
        return BodyPart.front;
      case 'Back':
        return BodyPart.back;
      case 'Interior':
        return BodyPart.interior;
      default:
        return BodyPart.interior;
    }
  }

  String get value {
    switch (this) {
      case BodyPart.top:
        return 'Top';
      case BodyPart.left:
        return 'Left';
      case BodyPart.right:
        return 'Right';
      case BodyPart.front:
        return 'Front';
      case BodyPart.back:
        return 'Back';
      case BodyPart.interior:
        return 'Interior';
    }
  }

  /// Localized display label for each body part
  String label() {
    switch (this) {
      case BodyPart.top:
        return FTexts.bodyPartTop.tr;
      case BodyPart.left:
        return FTexts.bodyPartLeft.tr;
      case BodyPart.right:
        return FTexts.bodyPartRight.tr;
      case BodyPart.front:
        return FTexts.bodyPartFront.tr;
      case BodyPart.back:
        return FTexts.bodyPartBack.tr;
      case BodyPart.interior:
        return FTexts.bodyPartInterior.tr;
    }
  }
}
