part of '../selection.dart';

Selection _$SelectionFromJson(Map json) {

  if (json['id'] != null && json['id'] != 'none') {
    final label = (json['label'] ?? json['name']) ?? 'label';
    return Selection(value: '${json['id']}', label: label);
  } else {
    return Selection.empty();
  }
}

Map<String, dynamic> _$SelectionToJson(Selection instance) => <String, dynamic>{
  'id': instance.value,
  'label': instance.label,
  'name': instance.label,
};