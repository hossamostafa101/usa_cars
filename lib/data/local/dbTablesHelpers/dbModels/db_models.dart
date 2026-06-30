class NotificationItem {
  int? id;
  final String title;
  final String description;
  final String action;
  final String topic;


  NotificationItem({required this.title, required this.description, required this.action, required this.topic});

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'action': action,
    'topic': topic,
  };

  factory NotificationItem.fromMap(Map<String, dynamic> map) => NotificationItem(
    // id: map['id'],
    title: map['title'],
    description: map['description'],
    action: map['action'],
    topic: map['topic'],
  );
}

class RideItem {
  final int id;
  final int userId;
  final int carId;
  final String departureDate;
  final String departureTime;
  final String startLat;
  final String startLng;
  final String startName;
  final String destLat;
  final String destLng;
  final String destName;
  final int seats;
  final int price;
  final String description;


  RideItem({
    required this.id,
    required this.userId,
    required this.carId,
    required this.departureDate,
    required this.departureTime,
    required this.startLat,
    required this.startLng,
    required this.startName,
    required this.destLat,
    required this.destLng,
    required this.destName,
    required this.seats,
    required this.price,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'carId': carId,
    'departureDate': departureDate,
    'departureTime': departureTime,
    'startLat': startLat,
    'startLng': startLng,
    'startName': startName,
    'destLat': destLat,
    'destLng': destLng,
    'destName': destName,
    'seats': seats,
    'price': price,
    'description': description,
  };

  factory RideItem.fromMap(Map<String, dynamic> map) => RideItem(
    id: map['id'],
    userId: map['userId'],
    carId: map['carId'],
    departureDate: map['departureDate'],
    departureTime: map['departureTime'],
    startLat: map['startLat'],
    startLng: map['startLng'],
    startName: map['startName'],
    destLat: map['destLat'],
    destLng: map['destLng'],
    destName: map['destName'],
    seats: int.parse(map['seats'].toString()),
    price: int.parse(map['price'].toString()),
    description: map['description'],
  );
}

