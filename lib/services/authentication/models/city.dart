class City{
  int id;
  String city;

  City({required this.id, required this.city});

  tojson() => {'id': id, 'name': city};

  static City? set(Map? value) {
    if (value == null) return null;

    final id = value['id'] as int?;
    final name = value['name']?.toString();

    if (id == null || id == 0 || name == null || name.isEmpty) return null;

    return City(id: id, city: name);
  }

  @override
  String toString() {
    return city;
  }

  operator ==(Object other) =>
      identical(this, other) ||
      other is City && runtimeType == other.runtimeType && id == other.id;
}
