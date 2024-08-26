import 'package:do_am_thanh/app_model.dart';
import 'package:do_am_thanh/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppModel(),
      child: Consumer<AppModel>(
          builder: (BuildContext context, value, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            brightness: value.isLight ? Brightness.light : Brightness.dark,
          )),
          home: SplashScreen(),
        );
      }),
    );
  }
}
