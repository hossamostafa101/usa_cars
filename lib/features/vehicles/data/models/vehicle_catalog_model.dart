class VehicleMakeModel {
  final int? id;
  final String name;

  const VehicleMakeModel({
    this.id,
    required this.name,
  });

  factory VehicleMakeModel.fromJson(Map<String, dynamic> json) {
    return VehicleMakeModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class VehicleModelOption {
  final int? id;
  final int? makeId;
  final String name;

  const VehicleModelOption({
    this.id,
    this.makeId,
    required this.name,
  });

  factory VehicleModelOption.fromJson(Map<String, dynamic> json) {
    return VehicleModelOption(
      id: _toInt(json['id']),
      makeId: _toInt(json['make_id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}