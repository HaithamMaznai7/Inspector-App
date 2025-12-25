import 'dart:io';

import 'package:fahis_inspector/util/constants/enums.dart';
import 'package:fahis_inspector/util/formatters/formatter.dart';

class Point {
  int id;
  String title;
  String description;
  PointType category;

  PointStatus _status = PointStatus.none;

  PointStatus get status => _status;
  set setStatus(PointStatus? value) => _status = value ?? PointStatus.none;

  String? _note;

  String? get note => _note;
  set note(String? value) {
    _note = value ?? '';
  }

  String? _image;

  String? get image => EFormatter.formatImageUrl(_image);

  set image(String? value) {
    _image = value;
  }

  File? _file;

  File? get file => _file;

  set file(File? value) {
    _file = value;
  }

  Point({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    String? status,
    String? note,
    String? image,
  }) {
    _status = PointStatus.set(status);
    _note = note ?? '';
    if (image != '' && image != null && image != 'null') {
      _image = image;
    }
  }

  factory Point.set(Map point) => Point(
    id: point['id'],
    title: point['title'],
    description: point['description'] ?? '',
    category: PointType.set(point['type']),
    status: point['status'],
    note: point['note'],
    image: point['image'],
  );

  static List<Point> setList(List<dynamic> points) =>
      points.map((point) => Point.set(point)).toList();

  toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': category.toJson(),
    'status': status.value,
    'note': note,
    'image': image,
  };
}

class Category {
  PointType category;
  int all;
  int good;
  int note;
  int none;
  List<Point> points;

  Category({
    required this.category,
    required this.all,
    required this.good,
    required this.note,
    required this.none,
    required this.points,
  });

  static Category set(PointType category, List<Point> points) {
    return Category(
      category: category,
      all: points.length,
      good: points
          .where((point) => point.status == PointStatus.good)
          .toList()
          .length,
      note: points
          .where((point) => point.status == PointStatus.note)
          .toList()
          .length,
      none: points
          .where((point) => point.status == PointStatus.none)
          .toList()
          .length,
      points: points,
    );
  }
}

class PointType {
  int id;
  String title;
  String icon;

  PointType({required this.id, required this.title, required this.icon});

  factory PointType.set(Map cat) {
    return PointType(id: cat['id'], title: cat['title'], icon: cat['icon']);
  }

  toJson() => {'id': id, 'title': title, 'icon': icon};
}

class ReviewPoint {
  int all;
  int good;
  int note;
  int none;
  List<Category> cats;

  ReviewPoint({
    required this.all,
    required this.good,
    required this.note,
    required this.none,
    required this.cats,
  });

  factory ReviewPoint.set(List<Point> points) {
    final uniqueCategories = <PointType>[];
    final categories = <Category>[];

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
        Category.set(
          cat,
          points.where((point) => point.category.id == cat.id).toList(),
        ),
      );
    }

    return ReviewPoint(
      all: points.length,
      good: points
          .where((point) => point.status == PointStatus.good)
          .toList()
          .length,
      note: points
          .where((point) => point.status == PointStatus.note)
          .toList()
          .length,
      none: points
          .where((point) => point.status == PointStatus.none)
          .toList()
          .length,
      cats: categories,
    );
  }
}
