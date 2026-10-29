class CustomerNotificationModel {
  final int id;
  final String title;
  final String body;

  final String? type;
  final String? referenceType;
  final int? referenceId;

  final bool isRead;

  final DateTime? readAt;
  final DateTime? createdAt;

  const CustomerNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.type,
    this.referenceType,
    this.referenceId,
    this.readAt,
    this.createdAt,
  });

  factory CustomerNotificationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CustomerNotificationModel(
      id: _toInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: _nullableString(json['type']),
      referenceType:
      _nullableString(json['reference_type']),
      referenceId:
      _toInt(json['reference_id']),
      isRead: _toBool(json['is_read']),
      readAt: _toDate(json['read_at']),
      createdAt: _toDate(json['created_at']),
    );
  }

  CustomerNotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    String? type,
    String? referenceType,
    int? referenceId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return CustomerNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceType:
      referenceType ?? this.referenceType,
      referenceId:
      referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    if (value is num) {
      return value != 0;
    }

    final string =
    value?.toString().toLowerCase();

    return string == 'true' ||
        string == '1';
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static String? _nullableString(
      dynamic value,
      ) {
    if (value == null) return null;

    final result = value.toString().trim();

    return result.isEmpty
        ? null
        : result;
  }
}