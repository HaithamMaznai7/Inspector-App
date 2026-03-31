import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccessRequestController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final noteController = TextEditingController();

  RxBool isSubmitting = false.obs;

  Future<void> submitRequest() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;

    try {
      final note = noteController.text.trim();

      await FirebaseFirestore.instance.collection('access_requests').add({
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'city': cityController.text.trim(),
        if (note.isNotEmpty) 'note': note,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'source': 'inspector_app',
      });

      AppLogger.info('AccessRequest', 'Request submitted successfully');
      Get.offAllNamed(RoutingUrl.requestSuccess);
    } catch (e) {
      AppLogger.error('AccessRequest', 'Failed to submit request', e);
      FLoader.errorSnackBar(
        title: AccessRequestPage.submissionFailed.tr,
        message: AccessRequestPage.submissionFailedMsg.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
