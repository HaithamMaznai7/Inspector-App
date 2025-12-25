// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// // import 'package:fahis_inspector/app.dart';
// // import 'package:flutter/material.dart';
// // import 'package:hive_flutter/hive_flutter.dart';

// // import 'package:fahis_inspector/main.dart';

// // import 'counter_test.dart';

// // void main() {
// //   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
// //     // Build our app and trigger a frame.
// //     await tester.pumpWidget(App());

// //     // Verify that our counter starts at 0.
// //     expect(find.text('0'), findsOneWidget);
// //     expect(find.text('1'), findsNothing);

// //     // Tap the '+' icon and trigger a frame.
// //     await tester.tap(find.byIcon(Icons.add));
// //     await tester.pump();

// //     // Verify that our counter has incremented.
// //     expect(find.text('0'), findsNothing);
// //     expect(find.text('1'), findsOneWidget);
// //   });
// // }

// import 'package:get/get.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'auth_service_test.dart';

// void main() {
//   test('Services Initialized', () async {
//     // Start Services
//     await Get.putAsync<AuthService>(
//       () => AuthService.init(),
//       permanent: true,
//       tag: 'AuthService',
//     );

//     AuthService.check;

//     expect(AuthService.token, false);
//   });
// }
