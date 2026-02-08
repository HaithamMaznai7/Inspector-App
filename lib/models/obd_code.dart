import 'package:json_annotation/json_annotation.dart';

part 'serializables/obd_code.g.dart';

@JsonSerializable()
class OBDCode {

  int id ;
  String code ;
  String description ;

  OBDCode({this.id = 0, this.code = 'New Code', this.description = 'Unknown Description'});  

  static List<OBDCode> setList(List codes) =>
    codes.isEmpty ? [] : codes.map((code) => OBDCode.fromJson(code)).toList();
  
  factory OBDCode.fromJson(Map json) =>
      _$OBDCodeFromJson(json);
      
  Map<String, dynamic> toJson() => _$OBDCodeToJson(this);
}