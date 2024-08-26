import 'package:flutter/foundation.dart';

class Note {
  int id;
  String tieuDe;
  String body;
  int isMarked;
  int size;
  int style;
  int weight;
  int underline;
  Uint8List? picture;
  String date;

  Note({
    required this.id,
    required this.tieuDe,
    required this.body,
    required this.isMarked,
    required this.size,
    required this.style,
    required this.weight,
    required this.underline,
    this.picture,
    required this.date,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      tieuDe: map['tieu_de'],
      body: map['body'],
      isMarked: map['is_marked'],
      size: map['size'],
      style: map['style'],
      weight: map['weight'],
      underline: map['underline'],
      picture: map['picture'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "tieu_de": tieuDe,
        "is_marked": isMarked,
        "body": body,
        "size": size,
        "style": style,
        "weight": weight,
        "underline": underline,
        "picture": picture,
        "date": date,
      };
}

class BaoThuc {
  final int id;
  String lapLai;

  BaoThuc({required this.id, required this.lapLai});

  factory BaoThuc.fromMap(Map<String, dynamic> map) {
    return BaoThuc(
      id: map['id'],
      lapLai: map['lap_lai'],
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "lap_lai": lapLai,
      };
}
