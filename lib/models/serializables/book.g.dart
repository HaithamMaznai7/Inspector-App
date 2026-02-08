part of '../book.dart';

Book _$BookFromJson(Map<String, dynamic> json) {
  List availableCenters = json['available_centers'];
  List availableInspectors = json['available_inspector'];
  PlaceHolderModel? center;
  DateTime? date;
  if (json['book'] != null) {
    center = json['book']['branch'] != null
        ? PlaceHolderModel(
            id: json['book']['branch']['id'],
            label: json['book']['branch']['name'],
          )
        : null;
    date = json['book']['date'] != null
        ? DateTime.parse(json['book']['date'])
        : null;
  }
  PlaceHolderModel? inspector = json['inspector'] != null
      ? PlaceHolderModel(
          id: json['inspector']['id'],
          label: json['inspector']['name'],
        )
      : null;
  final book = Book(
    availableCenters: availableCenters
        .map((item) => PlaceHolderModel(id: item['id'], label: item['name']))
        .toList(),
    branch: center,
    availableInspectors: availableInspectors
        .map((item) => PlaceHolderModel(id: item['id'], label: item['name']))
        .toList(),
    inspector: inspector,
    date: date,
  );
  return book;
}

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'availableCenters': instance.availableCenters
      .map((element) => element.toJson())
      .toList(),
  'branch': instance.branch,
  'availableInspectors': instance.availableInspectors
      .map((element) => element.toJson())
      .toList(),
  'inspector': instance.inspector,
  'date': instance.date,
};
