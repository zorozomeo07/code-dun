import 'package:flutter/material.dart';
import 'package:note/app_model.dart';
import 'package:note/data/rest_ful_api.dart';
import 'package:note/screens/alarm_screen.dart';
import 'package:note/screens/note_screen.dart';
import 'package:note/screens/setting_screen.dart';
import 'package:note/widgets/buttons.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _PageStack(),
            ),
            orientation == Orientation.portrait ? _TabMenu() : Container(),
          ],
        ),
      ),
    );
  }
}

class _PageStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int index = context.select((AppModel model) => model.selectedIndex);
    Widget? page;
    if (index == 0) page = NoteScreen();
    if (index == 1) page = AlarmScreen();
    if (index == 2) page = SettingScreen();
    return FocusTraversalGroup(child: page ?? Container());
  }
}

class _TabMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void changePage(int value) =>
        context.read<AppModel>().selectedIndex = value;

    int index = context.select((AppModel m) => m.selectedIndex);
    return Container(
      height: 80,
      decoration: BoxDecoration(
          color: Colors.teal.shade50,
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 2, offset: Offset(0, -1))
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: SelectedPageButton(
                onPressed: () => changePage(0),
                label: "Note",
                isSelected: index == 0,
                icon: Icons.sticky_note_2),
          ),
          Expanded(
            child: SelectedPageButton(
                onPressed: () async {
                  context.read<AppModel>().baoThucList = await getBaoThucList();
                  changePage(1);
                },
                label: "Báo thức",
                isSelected: index == 1,
                icon: Icons.alarm),
          ),
          Expanded(
            child: SelectedPageButton(
                onPressed: () => changePage(2),
                label: "Cài đặt",
                isSelected: index == 2,
                icon: Icons.settings),
          ),
        ],
      ),
    );
  }
}
