import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/models/point_type.dart';
import 'package:fahis_inspector/models/point.dart';

class PointCategory {
  PointType category;
  int all;
  int good;
  int note;
  int none;
  List<Point> points;

  PointCategory({
    required this.category,
    required this.all,
    required this.good,
    required this.note,
    required this.none,
    required this.points,
  });

  static PointCategory set(PointType category, List<Point> points) {
    return PointCategory(
      category: category,
      all: points.length,
      good: points
          .where((point) => point.status.value == PointStatus.good.value)
          .toList()
          .length,
      note: points
          .where((point) => point.status.value == PointStatus.note.value)
          .toList()
          .length,
      none: points
          .where((point) => point.status.value == PointStatus.none.value)
          .toList()
          .length,
      points: points,
    );
  }
}
