import 'package:flutter/material.dart';

class TiengOnLevelDialog extends StatelessWidget {
  const TiengOnLevelDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Mức độ tiếng ồn'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '  >120dB: Tiếng sấm\n  >110dB: Nhạc rock\n  >100dB: Tàu điện ngầm\n  >90dB: Nhà máy\n  >80dB: Phố đông đúc\n  >70dB: Giao thông đông đúc\n  >60dB: Hội thoại\n  >50dB: Thư viện yên tĩnh\n  >40dB: Công viên yên tĩnh\n  >30dB: Thì thầm\n  >20dB: Lá rơi',
              style: TextStyle(fontSize: 16)),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'))
      ],
    );
  }
}
