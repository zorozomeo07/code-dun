import 'package:do_am_thanh/screens/history_screen.dart';
import 'package:flutter/material.dart';

class HistoryButton extends StatelessWidget {
  const HistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(Icons.history),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HistoryScreen()));
        },
      ),
    );
  }
}
