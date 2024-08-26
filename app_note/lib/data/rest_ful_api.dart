import 'package:note/data/data.dart';
import 'package:note/global/global_variable.dart';
import 'package:sqflite/sqflite.dart';

Future<List<Note>> getNoteList() async {
  final db = await database;

  final List<Map<String, Object?>> noteListMap = await db.query('note');

  return [for (final note in noteListMap) Note.fromMap(note)];
}

Future<void> insertNote(Note note) async {
  final db = await database;

  await db.insert(
    'note',
    note.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateNote(Note note) async {
  final db = await database;

  await db.update('note', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
}

Future<void> deleteNote(int id) async {
  final db = await database;

  await db.delete(
    'note',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<List<BaoThuc>> getBaoThucList() async {
  final db = await database;

  final List<Map<String, Object?>> baoThucListMap = await db.query('bao_thuc');

  return [for (final baoThuc in baoThucListMap) BaoThuc.fromMap(baoThuc)];
}

Future<void> insertBaoThuc(BaoThuc baoThuc) async {
  final db = await database;

  await db.insert(
    'bao_thuc',
    baoThuc.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateBaoThuc(BaoThuc baoThuc) async {
  final db = await database;

  await db.update('bao_thuc', baoThuc.toMap(),
      where: 'id = ?', whereArgs: [baoThuc.id]);
}

Future<void> deleteBaoThuc(int id) async {
  final db = await database;

  await db.delete(
    'bao_thuc',
    where: 'id = ?',
    whereArgs: [id],
  );
}
