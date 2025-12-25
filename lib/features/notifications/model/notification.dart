class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final String url;
  DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.url,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.set(Map map) {
    return NotificationModel(
      id: map['id'],
      type: map['type'],
      title: map['data']['title'],
      description: map['data']['description'],
      url: map['data']['url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  static List<NotificationModel> setList(List notifications) => notifications
      .map((notification) => NotificationModel.set(notification))
      .toList();

  Map<String, dynamic> toJson() => {'id': id};
}
