// import 'package:fahis_inspector/services/authentication/models/user.dart';
// import 'package:fahis_inspector/services/authentication/repository/auth_repository.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AuthService extends GetxService {
//   static AuthService? get instance =>
//       Get.isRegistered<AuthService>(tag: 'AuthService')
//       ? Get.find<AuthService>(tag: 'AuthService')
//       : null;

//   final Box _box;

//   AuthService(this._box);
  
//   Rxn<User> currentUser = Rxn<User>();

//   // Stored Token
//   static String? get token => AuthService.instance?.getToken;

//   String? get getToken => _box.get('USER_TOKEN');

//   set setToken(String? value) => _box.put('USER_TOKEN', value);

//   // Stored User
//   static User? get user => AuthService.instance?.currentUser.value;

//   static Rxn<User> get userO =>
//       AuthService.instance?.currentUser ?? Rxn<User>();

//   User? get getUser => User.set(_box.get('USER_DATA'));

//   saveUser() => _box.put('USER_DATA', currentUser.value?.toJson());

//   bool get isCheck => currentUser.value != null;

//   static bool get check => AuthService.instance?.isCheck ?? false;
//   // //Repositories
//   // User? get user => User.set(_box.get('USER_DATA'));

//   // set setUser(User value) => _box.put('USER_DATA', value.toJson());
//   /// Called during app initialization
//   static Future<AuthService> init() async {
//     // print('===>>> initializing Hive...');
//     await Hive.initFlutter();
//     print('## Hive has initialized.');

//     print('===>>> initializing Hive...');
//     final box = await Hive.openBox(AuthRepository.authBox);
//     print('## Hive has initialized.');
//     final auth = AuthService(box);
//     // if (auth.getToken != null) {
//     //   await auth.fetchUser();
//     // }

//     return auth;
//   }

//   Future<void> fetchUser() async {
//     try {
//       final res = await http.get(
//         Uri.parse('http://10.0.2.2:8000/api/user'),
//         headers: {'Authorization': 'Bearer $getToken'},
//       );
//       if (res.statusCode == 200) {
//         currentUser.value = User.set(json.decode(res.body));
//         saveUser();
//       }
//     } catch (e) {
//       print('error on fetch user data');
//       // logout();
//     }
//   }

//   Future<void> login({required String email, required String password}) async {
//     final res = await http.post(
//       Uri.parse('http://10.0.2.2:8000/api/login'),
//       body: {'email_or_phone': email, 'password': password},
//     );

//     if (res.statusCode == 200) {
//       final data = json.decode(res.body);
//       setToken = data['token'];
//       await fetchUser();
//     } else {
//       Get.snackbar("Error", "Invalid credentials");
//     }
//   }

//   void logout() {
//     currentUser.value = null;
//     saveUser();
//     setToken = null;
//   }
// }
