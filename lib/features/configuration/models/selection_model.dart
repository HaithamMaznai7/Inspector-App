import 'package:fahis_inspector/util/constants/text_strings.dart';

class Selection {
  String? value;
  String label;

  Selection({this.value, required this.label});

  static Selection set(data) {
    if (data['id'] != null && data['id'] != 'none') {
      final label = (data['label'] ?? data['name']) ?? 'label';
      return Selection(value: '${data['id']}', label: '${label}');
    } else {
      return Selection.empty();
    }
  }

  toJson() => {
    'id': value,
    'label': label,
    'name': label,
  };

  static Selection empty() {
    return Selection(label: FTexts.unSelected);
  }

  static List<Selection> setList(List<dynamic>? data) {
    return data != null ? data.map((item) => Selection.set(item)).toList() : [];
  }

  @override
  String toString() {
    return value ?? 'Undefined';
  }

  bool isEmpty() {
    return value == null;
  }
  
  bool isNotEmpty() {
    return ! isEmpty();
  }

  operator ==(Object other) =>
      identical(this, other) ||
      other is Selection &&
          runtimeType == other.runtimeType &&
          value == other.value;
}
