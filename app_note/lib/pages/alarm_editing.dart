import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flextras/flextras.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note/app_model.dart';
import 'package:note/data/data.dart';
import 'package:note/data/rest_ful_api.dart';
import 'package:note/global/global_variable.dart';
import 'package:note/global/my_color.dart';
import 'package:note/global/styling.dart';
import 'package:note/widgets/buttons.dart';
import 'package:provider/provider.dart';

class AlarmEditing extends StatefulWidget {
  AlarmEditing({super.key, this.alarmSettings, required this.lapLaiList});
  final AlarmSettings? alarmSettings;
  final List<bool> lapLaiList;

  @override
  State<AlarmEditing> createState() => _AlarmEditingState();
}

class _AlarmEditingState extends State<AlarmEditing> {
  bool loading = false;
  late Duration duration;
  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      duration = Duration(
          hours: selectedDateTime.hour, minutes: selectedDateTime.minute);
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/sound_1.mp3';
    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      duration = Duration(
          hours: selectedDateTime.hour, minutes: selectedDateTime.minute);
      _controller.text = widget.alarmSettings!.notificationBody;

      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
        : widget.alarmSettings!.id;
    var lapLai = '';

    for (int i = 0; i < widget.lapLaiList.length; i++) {
      if (widget.lapLaiList[i]) lapLai += '$i';
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: (widget.lapLaiList.every((e) => e == false))
          ? selectedDateTime
          : selectedDateTime.next(int.parse(lapLai.characters.first)),
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle:
          'Báo thức: ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')} đang rung!!',
      notificationBody: _controller.text,
      enableNotificationOnKill: true,
    );
    return alarmSettings;
  }

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);
    final alarm = buildAlarmSettings();
    Alarm.set(alarmSettings: alarm).then((res) async {
      if (res) {
        if (widget.lapLaiList.every((e) => e == false)) {
        } else {
          var lapLai = '';
          for (int i = 0; i < widget.lapLaiList.length; i++) {
            if (widget.lapLaiList[i]) lapLai += '$i';
          }
          final baoThuc = BaoThuc(id: alarm.id, lapLai: lapLai);
          insertBaoThuc(baoThuc);
        }
        context.read<AppModel>().baoThucList = await getBaoThucList();
        Navigator.pop(context, true);
      }
      setState(() => loading = false);
    });
  }

  void deleteAlarm() {
    Alarm.stop(widget.alarmSettings!.id).then((res) async {
      if (res) {
        deleteBaoThuc(widget.alarmSettings!.id);
        context.read<AppModel>().baoThucList = await getBaoThucList();
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String getButtonTitle(int index) {
      return switch (index) {
        0 => 'CN',
        1 => 'T2',
        2 => 'T3',
        3 => 'T4',
        4 => 'T5',
        5 => 'T6',
        6 => 'T7',
        _ => ''
      };
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Insets.large),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text('Hủy', style: TextStyles.h3),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  Text('Tùy chỉnh báo thức', style: TextStyles.h2),
                  TextButton(
                    child: Text('Lưu', style: TextStyles.h3),
                    onPressed: saveAlarm,
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: SeparatedColumn(
                    separatorBuilder: () => Divider(),
                    children: [
                      RawMaterialButton(
                        onPressed: pickTime,
                        fillColor: Colors.grey[100],
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          child: Text(
                            TimeOfDay.fromDateTime(selectedDateTime)
                                .format(context),
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(color: MyColors.color),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Lặp lại', style: TextStyles.h2),
                          Text(widget.lapLaiList.every((e) => e == false)
                              ? 'Một lần'
                              : 'Tùy chình'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < 7; i++)
                            Expanded(
                              child: NgayThuButton(
                                isSelected: widget.lapLaiList[i],
                                title: getButtonTitle(i),
                                onPressed: () {
                                  if (widget.lapLaiList[i] == true) {
                                    setState(
                                        () => widget.lapLaiList[i] = false);
                                  } else {
                                    setState(() => widget.lapLaiList[i] = true);
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tiêu đề',
                              style: TextStyles.h2,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                    isDense: true, border: InputBorder.none),
                              ),
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lặp lại nhạc chuông',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Switch(
                            value: loopAudio,
                            onChanged: (value) =>
                                setState(() => loopAudio = value),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rung',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Switch(
                            value: vibrate,
                            onChanged: (value) =>
                                setState(() => vibrate = value),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nhạc chuông',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          DropdownButton(
                            value: assetAudio,
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'assets/sound_1.mp3',
                                child: Text('Clock Alarm'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'assets/sound_2.mp3',
                                child: Text('Clock Alarm 2'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'assets/sound_3',
                                child: Text('Digital Alarm'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'assets/sound_4.mp3',
                                child: Text('Bell Ringing'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'assets/sound_5.mp3',
                                child: Text('Clockwav'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'assets/sound_6.mp3',
                                child: Text('Clock Short'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'assets/sound_7.mp3',
                                child: Text('Digital Alarm 2'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => assetAudio = value!),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Âm lượng',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Switch(
                            value: volume != null,
                            onChanged: (value) =>
                                setState(() => volume = value ? 0.5 : null),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                        child: volume != null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    volume! > 0.7
                                        ? Icons.volume_up_rounded
                                        : volume! > 0.1
                                            ? Icons.volume_down_rounded
                                            : Icons.volume_mute_rounded,
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: volume!,
                                      onChanged: (value) {
                                        setState(() => volume = value);
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ),
                      if (!creating)
                        TextButton(
                          onPressed: deleteAlarm,
                          child: Text(
                            'Xóa báo thức',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
