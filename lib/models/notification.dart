import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'serializables/notification.g.dart';

@JsonSerializable()
class Notification {
  final String id;
  final String type;
  final String title;
  final String description;
  final String url;
  String? page;
  DateTime? readAt;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.url,
    this.page,
    this.readAt,
    required this.createdAt,
  });

  IconData get icon {
    return Iconsax.notification;
  }

  void read() async {
    readAt = DateTime.now();
  }

  void unread() async {
    readAt = null;
  }

  void onOpen() async {
    if (page != null) {
      Get.toNamed(page!);
    } else if (url.startsWith('http')) {
      await launchUrl(Uri.parse(url));
    }
    return;
  }

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
