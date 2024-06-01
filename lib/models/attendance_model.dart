import 'dart:convert';

class AttendanceModel {
  final bool success;
  final String message;
  final List<Attendance> data;

  AttendanceModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AttendanceModel.fromRawJson(String str) =>
      AttendanceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        success: json["success"],
        message: json["message"],
        data: List<Attendance>.from(
          json["data"].map((x) => Attendance.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Attendance {
  final int id;
  final String latitude;
  final String longitude;
  final int status;
  final String image;
  final String thumbnail;
  final int penilikId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.image,
    required this.thumbnail,
    required this.penilikId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromRawJson(String str) =>
      Attendance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        status: json["status"],
        image: json["image"],
        thumbnail: json["thumbnail"],
        penilikId: json["penilik_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "status": status,
        "image": image,
        "thumbnail": thumbnail,
        "penilik_id": penilikId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
