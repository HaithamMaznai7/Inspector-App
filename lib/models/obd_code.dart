import 'package:json_annotation/json_annotation.dart';

part 'serializables/obd_code.g.dart';

@JsonSerializable()
class OBDCode {

  int id ;
  String code ;
  String description ;

  // Transient: true while this entry is queued for offline sync and has not
  // yet been POSTed to the server. Never serialized — only set at runtime
  // when the repo rehydrates pending entries into the reactive list.
  bool isPending;

  OBDCode({this.id = 0, this.code = 'New Code', this.description = 'Unknown Description', this.isPending = false});

  static List<OBDCode> setList(List codes) =>
    codes.isEmpty ? [] : codes.map((code) => OBDCode.fromJson(code)).toList();
  
  factory OBDCode.fromJson(Map json) =>
      _$OBDCodeFromJson(json);
      
  Map<String, dynamic> toJson() => _$OBDCodeToJson(this);
}