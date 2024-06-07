import 'dart:convert';

class RoadModel {
  final bool success;
  final List<Road> data;
  final String message;

  RoadModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory RoadModel.fromRawJson(String str) =>
      RoadModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoadModel.fromJson(Map<String, dynamic> json) => RoadModel(
        success: json["success"] ?? false,
        data: List<Road>.from(json["data"].map((x) => Road.fromJson(x))),
        message: json["message"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class Road {
  final int id;
  final String nama;
  final String slug;
  final String deskripsi;
  final String kordinat;
  final String panjang;
  final String lebar;
  final Image? image;
  final Image? thumbnail;
  final int wilayahId;
  final int authorId;
  final int penilikId;
  final Status? status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Road({
    required this.id,
    required this.nama,
    required this.slug,
    required this.deskripsi,
    required this.kordinat,
    required this.panjang,
    required this.lebar,
    this.image,
    this.thumbnail,
    required this.wilayahId,
    required this.authorId,
    required this.penilikId,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Road.fromRawJson(String str) => Road.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Road.fromJson(Map<String, dynamic> json) => Road(
        id: json["id"] ?? 0,
        nama: json["nama"],
        slug: json["slug"] ?? '',
        deskripsi: json["deskripsi"] ?? '',
        kordinat: json["kordinat"] ?? '',
        panjang: json["panjang"] ?? '',
        lebar: json["lebar"] ?? '',
        image: imageValues.map[json["image"]],
        thumbnail: imageValues.map[json["thumbnail"]],
        wilayahId: json["wilayah_id"] ?? 0,
        authorId: json["author_id"] ?? 0,
        penilikId: json["penilik_id"] ?? 0,
        status: statusValues.map[json["status"]],
        createdAt: DateTime.parse(
            json["created_at"] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json["updated_at"] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": namaValues.reverse[nama],
        "slug": slug,
        "deskripsi": deskripsi,
        "kordinat": kordinat,
        "panjang": panjang,
        "lebar": lebar,
        "image": imageValues.reverse[image],
        "thumbnail": imageValues.reverse[thumbnail],
        "wilayah_id": wilayahId,
        "author_id": authorId,
        "penilik_id": penilikId,
        "status": statusValues.reverse[status],
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

enum Image { DEFAULT_JPG }

final imageValues = EnumValues({"default.jpg": Image.DEFAULT_JPG});

enum Nama { JALAN_ARTERI_PRIMER }

final namaValues =
    EnumValues({"Jalan Arteri Primer": Nama.JALAN_ARTERI_PRIMER});

enum Status { JALAN_NASIONAL, JALAN_PROVINSI }

final statusValues = EnumValues({
  "Jalan Nasional": Status.JALAN_NASIONAL,
  "Jalan Provinsi": Status.JALAN_PROVINSI,
});

class EnumValues<T> {
  final Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
