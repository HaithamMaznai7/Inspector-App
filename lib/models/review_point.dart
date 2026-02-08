import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/models/point_category.dart';
import 'package:fahis_inspector/models/point_type.dart';

class ReviewPoint {
  int all;
  int good;
  int note;
  int none;
  List<PointCategory> cats;

  ReviewPoint({
    required this.all,
    required this.good,
    required this.note,
    required this.none,
    required this.cats,
  });

  factory ReviewPoint.set(List<Point> points) {
    final uniqueCategories = <PointType>[];
    final categories = <PointCategory>[];

    for (var point in points) {
      if (uniqueCategories
              .where((cat) => cat.id == point.category.id)
              .firstOrNull ==
          null) {
        uniqueCategories.add(point.category);
      }
    }

    for (PointType cat in uniqueCategories) {
      categories.add(
        PointCategory.set(
          cat,
          points.where((point) => point.category.id == cat.id).toList(),
        ),
      );
    }

    return ReviewPoint(
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
      cats: categories,
    );
  }
}
