import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:note/app_model.dart';
import 'package:note/data/data.dart';
import 'package:note/data/rest_ful_api.dart';
import 'package:note/global/my_color.dart';
import 'package:note/global/styling.dart';
import 'package:note/pages/alarm_editing.dart';
import 'package:note/pages/alarm_ring.dart';
import 'package:note/widgets/alarm_tile.dart';
import 'package:note/widgets/transition_route.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late List<AlarmSettings> alarms;
  static StreamSubscription<AlarmSettings>? subscription;

  @override
  void initState() {
    super.initState();
    if (Alarm.android) {
      checkAndroidNotificationPermission();
      checkAndroidScheduleExactAlarmPermission();
    }
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AlarmRing(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
    context.read<AppModel>().baoThucList = await getBaoThucList();
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    var res;
    List<bool> lapLaiList = [false, false, false, false, false, false, false];
    if (settings != null) {
      BaoThuc? baoThuc;
      for (final bt in context.read<AppModel>().baoThucList) {
        if (bt.id == settings.id) {
          baoThuc = bt;
        }
      }
      if (baoThuc != null) {
        final characters = baoThuc.lapLai.characters.toList();
        for (int i = 0; i < characters.length; i++) {
          final kiTu = characters[i];
          switch (kiTu) {
            case '0':
              lapLaiList[0] = true;
            case '1':
              lapLaiList[1] = true;
            case '2':
              lapLaiList[2] = true;
            case '3':
              lapLaiList[3] = true;
            case '4':
              lapLaiList[4] = true;
            case '5':
              lapLaiList[5] = true;
            case '6':
              lapLaiList[6] = true;
          }
        }
      }

      res = await Navigator.push(
          context,
          transitionRoute(
              AlarmEditing(alarmSettings: settings, lapLaiList: lapLaiList)));
    } else {
      res = await Navigator.push(
          context,
          transitionRoute(AlarmEditing(
            alarmSettings: settings,
            lapLaiList: lapLaiList,
          )));
    }
    if (res != null && res == true) loadAlarms();
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not '}granted',
      );
    }
  }

  Future<void> checkAndroidExternalStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      alarmPrint('Requesting external storage permission...');
      final res = await Permission.storage.request();
      alarmPrint(
        'External storage permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    alarmPrint('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      alarmPrint('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      alarmPrint(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Insets.large),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Báo thức',
                style: TextStyles.h3,
              ),
              IconButton(
                  onPressed: () {
                    navigateToAlarmScreen(null);
                  },
                  icon: Icon(
                    Icons.add,
                    color: MyColors.color,
                  ))
            ],
          ),
          Divider(),
          Expanded(
            child: alarms.isNotEmpty
                ? ListView.separated(
                    itemCount: alarms.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      var ngayLap = '';
                      BaoThuc? baoThuc;

                      for (final bt in context.read<AppModel>().baoThucList) {
                        if (bt.id == alarms[index].id) {
                          baoThuc = bt;
                        }
                      }
                      if (baoThuc == null) {
                        ngayLap = 'Một lần';
                      } else {
                        final characters = baoThuc.lapLai.characters.toList();
                        if (characters.length == 7) {
                          ngayLap = 'Mỗi ngày';
                        } else {
                          for (int i = 0; i < characters.length; i++) {
                            final kiTu = characters[i];
                            switch (kiTu) {
                              case '0':
                                ngayLap += 'CN';
                              case '1':
                                ngayLap += 'T2';
                              case '2':
                                ngayLap += 'T3';
                              case '3':
                                ngayLap += 'T4';
                              case '4':
                                ngayLap += 'T5';
                              case '5':
                                ngayLap += 'T6';
                              case '6':
                                ngayLap += 'T7';
                            }
                          }
                          ngayLap = StringUtils.addCharAtPosition(
                              ngayLap, ", ", 2,
                              repeat: true);
                        }
                      }
                      return AlarmTile(
                        key: Key(alarms[index].id.toString()),
                        title: TimeOfDay(
                          hour: alarms[index].dateTime.hour,
                          minute: alarms[index].dateTime.minute,
                        ).format(context),
                        subTitle: alarms[index].notificationBody,
                        lapLai: ngayLap,
                        isActive: Alarm.getAlarms()
                            .any((a) => a.id == alarms[index].id),
                        onToggle: (isActive) async {
                          try {
                            if (isActive) {
                              await Alarm.set(alarmSettings: alarms[index]);
                            } else {
                              await Alarm.stop(alarms[index].id);
                            }
                            loadAlarms();
                          } catch (e) {
                            // Handle errors here
                            print('Error setting/stopping alarm: $e');
                          }
                        },
                        onPressed: () => navigateToAlarmScreen(alarms[index]),
                        onDismissed: () {
                          Alarm.stop(alarms[index].id)
                              .then((_) => loadAlarms());
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Không có báo thức nào',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
