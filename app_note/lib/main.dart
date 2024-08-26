import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:note/app_model.dart';
import 'package:note/data/rest_ful_api.dart';
import 'package:note/global/global_variable.dart';
import 'package:note/global/my_color.dart';
import 'package:note/screens/splassh_screen.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  database = openDatabase(
    join(await getDatabasesPath(), 'note.db'),
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE note(id INTEGER PRIMARY KEY, tieu_de TEXT, body TEXT, is_marked INTEGER, size INTEGER, style INTEGER, weight INTEGER, underline INTEGER, picture BLOB, date TEXT)',
      );
      await db.execute(
        'CREATE TABLE bao_thuc(id INTEGER PRIMARY KEY, lap_lai TEXT)',
      );

      return;
    },
    version: 1,
  );
  initNoteList = await getNoteList();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: MyColors.color, brightness: Brightness.light)),
        home: SplashScreen(),
      ),
    );
  }
}
