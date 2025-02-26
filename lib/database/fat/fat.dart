class Fat {
  final String id;
  final String name;
  final String location;
  final int portCount;
  final DateTime lastMaintenance;
  final bool isActive;
  final double latitude;
  final double longitude;

  Fat({
    required this.id,
    required this.name,
    required this.location,
    required this.portCount,
    required this.lastMaintenance,
    required this.isActive,
    required this.latitude,
    required this.longitude,
  });

  factory Fat.fromJson(Map<String, dynamic> json) {
    return Fat(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      portCount: json['portCount'],
      lastMaintenance: DateTime.parse(json['lastMaintenance']),
      isActive: json['isActive'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'portCount': portCount,
      'lastMaintenance': lastMaintenance.toIso8601String(),
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Fat copyWith({
    String? id,
    String? name,
    String? location,
    int? portCount,
    DateTime? lastMaintenance,
    bool? isActive,
    double? latitude,
    double? longitude,
  }) {
    return Fat(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      portCount: portCount ?? this.portCount,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      isActive: isActive ?? this.isActive,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
} 