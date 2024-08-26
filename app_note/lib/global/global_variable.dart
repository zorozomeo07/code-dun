import 'package:note/data/data.dart';

late final database;
late List<Note> initNoteList;

extension DateTimeExtension on DateTime {
  DateTime next(int day) {
    return this.add(
      Duration(
        days: (day - this.weekday) % DateTime.daysPerWeek,
      ),
    );
  }
}
