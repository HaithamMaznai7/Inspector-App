// import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
// import 'package:fahis_inspector/models/placeholder_model.dart';
// import 'package:fahis_inspector/util/constants/api_endpoints.dart';
// import 'package:fahis_inspector/util/constants/colors.dart';
// import 'package:fahis_inspector/util/constants/sizes.dart';
// import 'package:fahis_inspector/util/device/device_utility.dart';
// import 'package:fahis_inspector/util/formatters/formatter.dart';
// import 'package:fahis_inspector/util/popups/full_screen_loader.dart';
// import 'package:fahis_inspector/routes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';

// class CenterSection extends StatelessWidget {
//   final controller = InspectionDetailsBinding().instance;
//   CenterSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     if (controller.inspection.value?.center != null) {
//       return Card(
//         margin: EdgeInsets.symmetric(
//           horizontal: FSizes.md,
//           vertical: FSizes.sm,
//         ),
//         color: FColors.grey,
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: FSizes.md,
//             vertical: FSizes.lg,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       String url =
//                           '${EndPoints.baseUrl}${EndPoints.inspections}${controller.inspection.value?.slug}';
//                       Clipboard.setData(ClipboardData(text: url));
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         FLoader.infoSnackBar(
//                           title: 'Copied to Clipboard',
//                           message: '$url copied to clipboard!',
//                           duration: 3,
//                         ),
//                       );
//                     },
//                     icon: Icon(Iconsax.copy, weight: 30),
//                   ),
//                   Text(
//                     '#${controller.inspection.value?.slug}',
//                     style: Theme.of(context).textTheme.labelMedium,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: FSizes.spaceBtwItems),
//               Row(
//                 children: [
//                   Flexible(
//                     flex: 3,
//                     child: Row(
//                       children: [
//                         const Icon(Iconsax.user),
//                         const SizedBox(width: FSizes.sm),
//                         SizedBox(
//                           width: FDeviceUtils.getScreenWidth() * .4,
//                           child: Text(
//                             '${controller.inspection.value?.center!.center.label}',
//                             style: Theme.of(context).textTheme.bodyLarge,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Flexible(
//                     flex: 2,
//                     child: Row(
//                       children: [
//                         const Icon(Iconsax.call),
//                         const SizedBox(width: FSizes.sm),
//                         SizedBox(
//                           width: FDeviceUtils.getScreenWidth() * .24,
//                           child: Text(
//                             '${controller.inspection.value?.center!.branch?.label}',
//                             style: Theme.of(context).textTheme.bodyLarge,
//                             overflow: TextOverflow.visible,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: FSizes.spaceBtwItems),
//               Row(
//                 children: [
//                   Flexible(
//                     flex: 3,
//                     child: Row(
//                       children: [
//                         const Icon(Iconsax.user),
//                         const SizedBox(width: FSizes.sm),
//                         SizedBox(
//                           width: FDeviceUtils.getScreenWidth() * .4,
//                           child: Text(
//                             '${controller.inspection.value?.center!.city?.label}',
//                             style: Theme.of(context).textTheme.bodyLarge,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Flexible(
//                     flex: 2,
//                     child: Row(
//                       children: [
//                         const Icon(Iconsax.call),
//                         const SizedBox(width: FSizes.sm),
//                         SizedBox(
//                           width: FDeviceUtils.getScreenWidth() * .24,
//                           child: Text(
//                             controller.inspection.value?.center?.datetime !=
//                                     null
//                                 ? EFormatter.getDateFormat.format(
//                                     controller
//                                         .inspection
//                                         .value!
//                                         .center!
//                                         .datetime!,
//                                   )
//                                 : ' YYYY-MM-DD HH:SS',
//                             style: Theme.of(context).textTheme.bodyLarge,
//                             overflow: TextOverflow.visible,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     } else {
//       return SizedBox();
//     }
//   }
// }

// class CenterBook extends StatelessWidget {
//   const CenterBook({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Booking'),
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           onPressed: () => FFullScreenLoader.stopLoading(),
//           icon: Icon(Iconsax.arrow_right_3),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: GetBuilder(
//           init: InspectionDetailsBinding().instance,
//           builder: (controller) {
//             final book = controller.inspectionBook.value;
//             if (book != null) {
//               return Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: FSizes.lg * 2,
//                   vertical: FSizes.lg * 3,
//                 ),
//                 child: Column(
//                   children: [
//                     SelectionInput<PlaceHolderModel>(
//                       itemLabel: (item) => item.label ?? '',
//                       items: book.availableCenters,
//                       onChanged: (PlaceHolderModel? center) async {
//                         if (center != null) {
//                           book.branch = center;

//                           await controller.updateSelectedCenter(
//                             book,
//                           ); // ⬅️ server call
//                         }
//                       },
//                       hintText: 'Select Center',
//                       selectedItem: book.branch,
//                     ),
//                     SizedBox(height: FSizes.spaceBtwSections),
//                     SelectionInput<PlaceHolderModel>(
//                       itemLabel: (item) => item.label ?? '',
//                       items: book.availableInspectors,
//                       onChanged: (PlaceHolderModel? val) async {
//                         book.inspector = val;
//                         await controller.updateSelectedCenter(
//                           book,
//                         ); // ⬅️ server call
//                       },
//                       hintText: 'Assign an inspector (optional)',
//                       selectedItem: book.inspector,
//                     ),
//                     SizedBox(height: FSizes.spaceBtwSections),
//                     Row(
//                       children: [
//                         ElevatedButton(
//                           onPressed: () async {
//                             book.date = DateTime.now();
//                             await controller.updateSelectedCenter(book);
//                           },
//                           child: Text('Now'),
//                         ),
//                         SizedBox(width: FSizes.spaceBtwItems),
//                         Flexible(
//                           child: GestureDetector(
//                             onTap: () async {
//                               final picked = await showDateTimePicker(
//                                 context,
//                                 initialDate: book.date,
//                               );
//                               if (picked != null) {
//                                 book.date = picked;
//                                 await controller.updateSelectedCenter(book);
//                               }
//                             },
//                             child: Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 16,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey.shade400),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 EFormatter.formattedWithTime(book.date) ??
//                                     'Book Date & Time',
//                                 style: Theme.of(context).textTheme.bodyLarge,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             } else {
//               return SizedBox();
//             }
//           },
//         ),
//       ),
//       floatingActionButton: Container(
//         padding: EdgeInsets.symmetric(horizontal: FSizes.lg),
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: () => FFullScreenLoader.stopLoading(),
//           child: Text('Save'),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }

// class SelectionInput<T> extends StatelessWidget {
//   final List<T> items;
//   final T? selectedItem;
//   final String Function(T) itemLabel;
//   final void Function(T?) onChanged;
//   final String hintText;

//   const SelectionInput({
//     Key? key,
//     required this.items,
//     required this.itemLabel,
//     required this.onChanged,
//     this.selectedItem,
//     this.hintText = 'Select an option',
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: FColors.white,
//       borderRadius: BorderRadius.circular(10),
//       child: DropdownButtonFormField<T>(
//         focusColor: Colors.red,
//         dropdownColor: FColors.white,
//         value: items.contains(selectedItem) ? selectedItem : null,
//         decoration: InputDecoration(
//           labelText: hintText,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//         icon: const Icon(Icons.arrow_drop_down),
//         items: items.map((T item) {
//           return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
//         }).toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }
// }

// Future<DateTime?> showDateTimePicker(
//   BuildContext context, {
//   DateTime? initialDate,
//   DateTime? firstDate,
//   DateTime? lastDate,
// }) async {
//   // Step 1: Pick date
//   final DateTime? pickedDate = await showDatePicker(
//     context: context,
//     initialDate: initialDate ?? DateTime.now(),
//     firstDate: lastDate ?? DateTime.now(),
//     lastDate: lastDate ?? DateTime.now().add(const Duration(days: 7)),
//   );

//   if (pickedDate == null) return null;

//   // Step 2: Pick time (only :00 and :30)
//   final selectedTime = await showModalBottomSheet<TimeOfDay>(
//     context: context,
//     builder: (_) {
//       final times = List.generate(48, (index) {
//         final hour = index ~/ 2;
//         final minute = index.isEven ? 0 : 30;
//         return TimeOfDay(hour: hour, minute: minute);
//       });

//       return ListView.builder(
//         itemCount: times.length,
//         itemBuilder: (_, i) {
//           final t = times[i];
//           return ListTile(
//             title: Text(t.format(context)),
//             onTap: () => Navigator.pop(context, t),
//           );
//         },
//       );
//     },
//   );

//   if (selectedTime == null) return null;

//   return DateTime(
//     pickedDate.year,
//     pickedDate.month,
//     pickedDate.day,
//     selectedTime.hour,
//     selectedTime.minute,
//   );
// }
