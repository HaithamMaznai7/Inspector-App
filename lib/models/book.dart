import 'placeholder_model.dart';

part 'serializables/book.g.dart';

class Book {
  List<PlaceHolderModel> availableCenters;
  PlaceHolderModel? branch;
  List<PlaceHolderModel> availableInspectors;
  PlaceHolderModel? inspector;
  DateTime? date;

  Book({
    required this.availableCenters,
    this.branch,
    required this.availableInspectors,
    this.inspector,
    this.date,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);
}
