import 'package:get/get.dart';
// import 'package:json_annotation/json_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

class StorageService extends GetxController {
  
  late Box auth;
  late Box<List> assets;
  late Box<List> inspections;

  @override
  void onInit() async {
    await Hive.initFlutter();

    auth = await Hive.openBox<List>('Auth');
    assets = await Hive.openBox<List>('Assets');
    inspections = await Hive.openBox<List>('Inspections');
  
    // await Hive.initFlutter();

    // auth = await Hive.openBox('User');
    // String path = join(await getDatabasesPath(), 'user_database.db');
    // _db = await openDatabase(
    //   path,
    //   onCreate: (db, version) {
    //     return db.execute(
    //       'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
    //     );
    //   },
    //   version: 1,
    // );
  }

  // Future<void> insertData(String table, Map<String, Object?> values) async {
  //   await _db.insert(
  //     table,
  //     values,
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // Future<List<Map<String, dynamic>>> getData(String table) async {
  //   final List<Map<String, dynamic>> maps = await _db.query(table);
  //   return List.generate(maps.length, (i) {
  //     return maps[i];
  //   });
  // }

  // Future<void> updateData(String table, Map<String, Object?> values, dynamic id) async {
  //   await _db.update(
  //     table,
  //     values,
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Future<void> deleteData(String table, dynamic id) async {
  //   await _db.delete(
  //     table,
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  void put(Box box, String key, String value){
    box.put(key, value);
  }

  String get(Box box, String key, {dynamic  defaultValue}){
    return box.get(key, defaultValue: defaultValue);
  }
}
