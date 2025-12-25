import 'package:fahis_inspector/features/inspections/models/inspection.dart';

class Book {
  List<ModelItem> availableCenters;
  ModelItem? branch;
  List<ModelItem> availableInspectors;
  ModelItem? inspector;
  DateTime? date;

  Book({
    required this.availableCenters,
    this.branch,
    required this.availableInspectors,
    this.inspector,
    this.date,
  });

  factory Book.fromMap(Map map) {
    List availableCenters = map['available_centers'];
    List availableInspectors = map['available_inspector'];
    ModelItem? center;
    DateTime? date;
    if (map['book'] != null) {
      center = map['book']['branch'] != null
          ? ModelItem(
              id: map['book']['branch']['id'],
              label: map['book']['branch']['name'],
            )
          : null;
      date = map['book']['date'] != null
          ? DateTime.parse(map['book']['date'])
          : null;
    }
    ModelItem? inspector = map['inspector'] != null
        ? ModelItem(id: map['inspector']['id'], label: map['inspector']['name'])
        : null;
    final book = Book(
      availableCenters: availableCenters
          .map((item) => ModelItem(id: item['id'], label: item['name']))
          .toList(),
      branch: center,
      availableInspectors: availableInspectors
          .map((item) => ModelItem(id: item['id'], label: item['name']))
          .toList(),
      inspector: inspector,
      date: date,
    );
    return book;
  }
}