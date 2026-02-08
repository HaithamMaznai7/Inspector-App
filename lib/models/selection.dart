import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/selection.g.dart';

@JsonSerializable()
class Selection {
  String? value;
  String label;

  Selection({this.value, this.label = FTexts.unSelected});

  factory Selection.fromJson(Map json) => _$SelectionFromJson(json);

  Map<String, dynamic> toJson() => _$SelectionToJson(this);

  static Selection empty() {
    return Selection(label: FTexts.unSelected);
  }

  static List<Selection> setList(List<dynamic>? data) {
    return data != null
        ? data.map((item) => Selection.fromJson(item)).toList()
        : [];
  }

  @override
  String toString() {
    return value ?? 'Undefined';
  }

  bool isEmpty() {
    return value == null;
  }

  bool isNotEmpty() {
    return !isEmpty();
  }

  bool isEquel(String? other) {
    return value == other;
  }

  operator ==(Object other) =>
      identical(this, other) ||
      other is Selection &&
          runtimeType == other.runtimeType &&
          value == other.value;
}
