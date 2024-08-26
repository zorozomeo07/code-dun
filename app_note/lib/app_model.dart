import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note/data/data.dart';
import 'package:note/global/global_variable.dart';

class AppModel with ChangeNotifier {
  // Main menu, selected page
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) => notify(() => _selectedIndex = value);

  Note _note = Note(
      id: 0,
      tieuDe: '',
      body: '',
      isMarked: 0,
      size: 16,
      style: 0,
      weight: 0,
      underline: 0,
      date: DateFormat('y.M.d').format(DateTime.now()));
  Note get note => _note;
  set note(Note value) => notify(() => _note = value);

  bool _closedFormat = true;
  bool get closedFormat => _closedFormat;
  set closedFormat(bool value) => notify(() => _closedFormat = value);

  List<Note> _noteList = initNoteList;
  List<Note> get noteList => _noteList;
  set noteList(List<Note> list) => notify(() => _noteList = list);

  List<BaoThuc> _baoThucList = [];
  List<BaoThuc> get baoThucList => _baoThucList;
  set baoThucList(List<BaoThuc> list) => notify(() => _baoThucList = list);

  // Helper method for single-line state changes
  void notify(VoidCallback stateChange) {
    stateChange.call();
    notifyListeners();
  }
}
