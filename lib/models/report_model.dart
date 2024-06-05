import 'dart:convert';

class ReportModel {
  final bool success;
  final String message;
  final List<Report> data;

  ReportModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReportModel.fromRawJson(String str) =>
      ReportModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        success: json["success"],
        message: json["message"],
        data: List<Report>.from(json["data"].map((x) => Report.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Report {
  final int id;
  final int penilikId;
  final String image;
  final String kondisi;
  final String latitude;
  final String longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.penilikId,
    required this.image,
    required this.kondisi,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromRawJson(String str) => Report.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"],
        penilikId: json["penilik_id"],
        image: json["image"],
        kondisi: json["kondisi"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "penilik_id": penilikId,
        "image": image,
        "kondisi": kondisi,
        "latitude": latitude,
        "longitude": longitude,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
