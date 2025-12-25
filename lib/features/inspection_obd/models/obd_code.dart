class OBDCode {

  int id ;
  String code ;
  String description ;

  OBDCode({this.id = 0, this.code = 'New Code', this.description = 'Unknown Description'});

  toJson() => {
    'id': id,
    'code': code,
    'description': description,
  };
  

  factory OBDCode.set(Map<String, dynamic> code) {
    return OBDCode(
      id: code['id'],
      code: code['code'],
      description: code['description'],
    );
  }

  static List<OBDCode> setList(List codes) =>
    codes.isEmpty ? [] : codes.map((code) => OBDCode.set(code)).toList();

}