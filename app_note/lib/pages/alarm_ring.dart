import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:note/data/data.dart';
import 'package:note/data/rest_ful_api.dart';
import 'package:note/global/global_variable.dart';
import 'package:note/global/my_color.dart';

class AlarmRing extends StatelessWidget {
  AlarmRing({super.key, required this.alarmSettings});

  final AlarmSettings alarmSettings;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Báo thức',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 30, color: MyColors.color),
            ),
            Icon(
              Icons.alarm,
              size: 200,
              color: Colors.yellow.shade700,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilledButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(MyColors.color),
                      foregroundColor: WidgetStatePropertyAll(Colors.white)),
                  onPressed: () {
                    final now = DateTime.now();
                    Alarm.set(
                      alarmSettings: alarmSettings.copyWith(
                        dateTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                        ).add(const Duration(minutes: 5)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Nhắc lại sau',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FilledButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.red,
                      ),
                      foregroundColor: WidgetStatePropertyAll(Colors.white)),
                  onPressed: () async {
                    BaoThuc? baoThuc;
                    final baoThucList = await getBaoThucList();
                    for (final bt in baoThucList) {
                      if (bt.id == alarmSettings.id) {
                        baoThuc = bt;
                      }
                    }
                    if (baoThuc == null) {
                      await deleteBaoThuc(alarmSettings.id);
                    } else {
                      baoThuc.lapLai = baoThuc.lapLai.substring(1) +
                          baoThuc.lapLai.substring(0, 1);
                      alarmSettings.dateTime
                          .next(int.parse(baoThuc.lapLai.characters.first));
                      Alarm.set(
                          alarmSettings: alarmSettings.copyWith(
                              dateTime: alarmSettings.dateTime.next(
                                  int.parse(baoThuc.lapLai.characters.first))));

                      insertBaoThuc(baoThuc);
                    }
                    Alarm.stop(alarmSettings
                            .copyWith(
                              vibrate: false,
                            )
                            .id)
                        .then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Tắt',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
