import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:do_am_thanh/app_model.dart';
import 'package:do_am_thanh/screens/history_screen.dart';
import 'package:do_am_thanh/screens/setting_screen.dart';
import 'package:do_am_thanh/styles.dart';
import 'package:do_am_thanh/widgets/history_button.dart';
import 'package:do_am_thanh/widgets/tieng_on_level_dialog.dart';
import 'package:flextras/flextras.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class PointChart {
  PointChart(this.time, this.decibel);
  final int time;
  final num decibel;
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<KdGaugeViewState> key = GlobalKey<KdGaugeViewState>();
  late FlutterSoundRecorder _record;

  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;
  double _minDecibel = 0.0;
  double _maxDecibel = 0.0;
  double _tbDecibel = 0.0;
  bool _amThanh = true;
  bool _visible = false;
  bool _manHinhBat = true;
  bool _xemBanLuu = true;
  int _canhBaoDB = 90;

  List<double> _count = <double>[];

  String _timer = '00:00:00';
  String _path = '';
  List<Map<String, String>> _markedList = <Map<String, String>>[];
  List<String> _historyList = <String>[];

  late List<PointChart> chartData;
  late TextEditingController _controller;
  late TextEditingController _controller2;

  late ChartSeriesController _chartSeriesController;

  int _hieuChinhValue = 0;

  Future<void> _saveBrightness() async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool('brightness', context.read<AppModel>().isLight);
  }

  Future<void> _loadBrightness() async {
    final pref = await SharedPreferences.getInstance();
    context.read<AppModel>().isLight = pref.getBool('brightness') ?? true;
  }

  Future<void> _loadAmThanh() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _amThanh = pref.getBool('am_thanh') ?? true;
    });
  }

  Future<void> _loadManHinhBat() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _manHinhBat = pref.getBool('man_hinh_bat') ?? true;
    });
    if (_manHinhBat) KeepScreenOn.turnOn();
  }

  Future<void> _loadXemBanLuu() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _xemBanLuu = pref.getBool('xem_ban_luu') ?? true;
    });
  }

  Future<void> _loadCanhBao() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _canhBaoDB = pref.getInt('canh_bao') ?? 90;
    });
  }

  Future<void> _saveHistory() async {
    final pref = await SharedPreferences.getInstance();
    pref.setStringList('history', _historyList);
  }

  Future<void> _loadHistory() async {
    final pref = await SharedPreferences.getInstance();
    _historyList = pref.getStringList('history') ?? [];
  }

  Future<void> _saveHieuChinh() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setInt('hieu_chinh', _hieuChinhValue);
    });
  }

  Future<void> _loadHieuChinh() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _hieuChinhValue = pref.getInt('hieu_chinh') ?? 0;
      key.currentState!.updateSpeed(_hieuChinhValue.toDouble(),
          animate: true, duration: Duration(seconds: 0));
    });
  }

  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  void onData(NoiseReading noiseReading) {
    setState(() => _latestReading = noiseReading);
  }

  void onError(Object error) {
    stopMeter();
  }

  Future<void> startMeter() async {
    noiseMeter ??= NoiseMeter();

    if (!(await checkPermission())) await requestPermission();

    _noiseSubscription = noiseMeter?.noise.listen(onData, onError: onError);
    setState(() => _isRecording = true);
  }

  void stopMeter() {
    _noiseSubscription?.cancel();
    setState(() => _isRecording = false);
  }

  void initRecord() async {
    var dir = await getTemporaryDirectory();
    _path = '${dir.path}/temp.wav';
    _record = FlutterSoundRecorder();
    await _record.openRecorder();
    await _record.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();

    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> startRecord() async {
    Directory dir = Directory(path.dirname(_path));
    if (!dir.existsSync()) {
      dir.createSync();
    }
    _record.openRecorder();
    await _record.startRecorder(
      toFile: _path,
      codec: Codec.pcm16WAV,
    );
    print('abc');
    StreamSubscription _recorderSubscription = _record.onProgress!.listen((e) {
      setState(() {
        _timer = e.duration.toString().padLeft(15, '0').substring(0, 8);
      });
    });
  }

  Future<String?> stopRecord() async {
    return await _record.stopRecorder();
  }

  int time = 0;
  void updateData(Timer timer) {
    chartData.add(PointChart(time++, (_count.isEmpty ? 0 : _count.last)));
    chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
    if (!_isRecording) timer.cancel();
  }

  List<PointChart> getChartData() {
    return <PointChart>[
      PointChart(0, 0),
      PointChart(-1, 0),
      PointChart(-2, 0),
      PointChart(-3, 0),
      PointChart(-4, 0),
      PointChart(-5, 0),
      PointChart(-6, 0),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload history when the widget dependencies change, such as when returning to the screen
    _saveHistory();
  }

  @override
  void initState() {
    initRecord();
    _loadAmThanh();
    _loadCanhBao();
    _loadManHinhBat();
    _loadXemBanLuu();
    _loadBrightness();
    chartData = getChartData();
    _loadHistory();
    _controller = TextEditingController();
    _controller2 = TextEditingController();
    _loadHieuChinh();
    super.initState();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_latestReading != null) {
      _count.add(_latestReading!.meanDecibel + _hieuChinhValue);
      _minDecibel = _count.reduce(min);
      _maxDecibel = _count.reduce(max);
      double sum = 0;
      for (final e in _count) sum += e;
      _tbDecibel = sum / _count.length;
      key.currentState!.updateSpeed(
          _latestReading!.meanDecibel + _hieuChinhValue,
          animate: true,
          duration: Duration(seconds: 0));
      _visible = _latestReading!.meanDecibel > _canhBaoDB;
    }

    String getMucDoTiengOn() {
      num value = _count.isEmpty ? 0 : _count.last;

      if (value > 120) {
        return 'Tiếng sét';
      } else if (value > 110) {
        return 'Nhạc rock';
      } else if (value > 100) {
        return 'Tàu điện ngầm';
      } else if (value > 90) {
        return 'Nhà máy';
      } else if (value > 80) {
        return 'Phố đông đúc';
      } else if (value > 70) {
        return 'Giao thông đông đúc';
      } else if (value > 60) {
        return 'Hội thoại';
      } else if (value > 50) {
        return 'Thư viện yên tĩnh';
      } else if (value > 40) {
        return 'Công viên yên tĩnh';
      } else if (value > 30) {
        return 'Thì thầm';
      } else if (value > 20) {
        return 'Lá rơi';
      } else {
        return '0';
      }
    }

    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: -1,
        onDestinationSelected: (value) {
          switch (value) {
            case 0:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()));
              break;

            case 1:
              showDialog(
                  context: context, builder: (context) => TiengOnLevelDialog());
              break;

            case 2:
              showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                          title: Text(
                            'Tăng hoặc giảm mức dB',
                            style: TextStyle(fontSize: 18),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _hieuChinhValue--;
                                      });
                                    },
                                    icon: Icon(
                                        Icons.remove_circle_outline_outlined),
                                    iconSize: 30,
                                  ),
                                  Text(
                                    '$_hieuChinhValue dB',
                                    style: Styles.body.copyWith(
                                        color: Colors.lightBlue, fontSize: 25),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _hieuChinhValue++;
                                      });
                                    },
                                    icon:
                                        Icon(Icons.add_circle_outline_outlined),
                                    iconSize: 30,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('HỦY')),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  OutlinedButton(
                                      onPressed: () {
                                        _saveHieuChinh();
                                        Navigator.pop(context);
                                      },
                                      child: Text('OK'))
                                ],
                              )
                            ],
                          ),
                        ),
                      ));
              break;
            case 3:
              context.read<AppModel>().toggle();
              _saveBrightness();
              break;
            case 4:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingScreen()));
          }
        },
        children: [
          Image.asset('images/drawer.jpg'),
          SizedBox(
            height: 5,
          ),
          NavigationDrawerDestination(
              icon: Icon(Icons.history), label: Text('Lịch sử')),
          NavigationDrawerDestination(
              icon: Icon(Icons.volume_up_outlined),
              label: Text('Mức độ tiếng ồn')),
          Divider(),
          NavigationDrawerDestination(
              icon: Icon(Icons.speed), label: Text('Hiệu chỉnh')),
          NavigationDrawerDestination(
              icon: Icon(context.read<AppModel>().isLight
                  ? Icons.dark_mode
                  : Icons.sunny),
              label: Text(context.read<AppModel>().isLight
                  ? 'Chủ đề tối'
                  : 'Chủ đề sáng')),
          NavigationDrawerDestination(
              icon: Icon(Icons.settings), label: Text('Cài đặt'))
        ],
      ),
      appBar: AppBar(
        title: Text('Đo âm thanh'),
        actions: [
          IconButton(
            icon: Icon(context.read<AppModel>().isLight
                ? Icons.dark_mode
                : Icons.sunny),
            onPressed: () {
              context.read<AppModel>().toggle();
              _saveBrightness();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SeparatedColumn(
          padding: EdgeInsets.all(8.0),
          separatorBuilder: () => SizedBox(
            height: 10,
          ),
          children: [
            SeparatedRow(
              separatorBuilder: () => SizedBox(
                width: 10,
              ),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Thấp nhất',
                      style: Styles.body.copyWith(fontSize: 14),
                    ),
                    Text('${_minDecibel.round()}',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500))
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Trung bình',
                      style: Styles.body.copyWith(fontSize: 14),
                    ),
                    Text('${_tbDecibel.round()}',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500))
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Cao nhất',
                      style: Styles.body.copyWith(fontSize: 14),
                    ),
                    Text('${_maxDecibel.round()}',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500))
                  ],
                )
              ],
            ),
            Stack(
              children: [
                Container(
                  width: 250,
                  height: 250,
                ),
                Positioned.fill(
                  child: KdGaugeView(
                    key: key,
                    minSpeed: 0,
                    maxSpeed: 120,
                    speed: _hieuChinhValue.toDouble(),
                    minMaxTextStyle: TextStyle(
                        fontSize: 20,
                        color: context.read<AppModel>().isLight
                            ? Colors.black
                            : Colors.white),
                    unitOfMeasurementTextStyle: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: context.read<AppModel>().isLight
                            ? Colors.black
                            : Colors.white),
                    speedTextStyle: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: context.read<AppModel>().isLight
                            ? Colors.black
                            : Colors.white),
                    animate: true,
                    duration: Duration(seconds: 0),
                    activeGaugeColor: Colors.lightBlue,
                    unitOfMeasurement: "Db",
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Text(getMucDoTiengOn(),
                        textAlign: TextAlign.center, style: Styles.body))
              ],
            ),
            SeparatedRow(
              separatorBuilder: () => SizedBox(
                width: 5,
              ),
              children: [
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () async {
                    if (_isRecording) {
                      stopMeter();
                      if (_amThanh) stopRecord();
                    }
                    _latestReading = null;
                    key.currentState!.updateSpeed(_hieuChinhValue.toDouble(),
                        animate: true, duration: Duration(seconds: 0));
                    setState(() {
                      _minDecibel = 0.0;
                      _maxDecibel = 0.0;
                      _tbDecibel = 0.0;
                      _count = <double>[];
                      _isRecording = false;
                      chartData = getChartData();
                      _visible = false;
                      _timer = '00:00:00';
                      _loadHistory();
                      _loadAmThanh();
                      _loadCanhBao();
                      _loadManHinhBat();
                      _loadXemBanLuu();
                      _loadBrightness();
                    });
                  },
                ),
                GestureDetector(
                  onTap: _isRecording
                      ? () {
                          stopMeter();
                          _loadHistory();
                          _loadAmThanh();
                          _loadCanhBao();
                          _loadManHinhBat();
                          _loadXemBanLuu();
                          _loadBrightness();
                          if (_amThanh) stopRecord();
                        }
                      : () {
                          startMeter();
                          if (_amThanh) startRecord();

                          Timer.periodic(
                              const Duration(milliseconds: 1000), updateData);
                        },
                  child: CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.lightBlue.shade100,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                        color: _isRecording ? Colors.white : Colors.blue,
                      ),
                      child: _isRecording
                          ? Container(
                              width: 20,
                              height: 20,
                              color: Colors.lightBlue.shade300,
                            )
                          : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.save,
                      color: _count.isNotEmpty ? null : Colors.grey),
                  onPressed: (_count.isNotEmpty && !_isRecording)
                      ? () async {
                          var audioString;
                          if (_amThanh) {
                            final file = File(_path);
                            Uint8List bytes = await file.readAsBytes();
                            audioString = base64.encode(bytes);
                          }

                          final map = {
                            'title':
                                'Recording ${_historyList.isEmpty ? 0 : _historyList.length}',
                            'thap_nhat': '${_minDecibel.round()}',
                            'trung_binh': '${_tbDecibel.round()}',
                            'cao_nhat': '${_maxDecibel.round()}',
                            'date_time':
                                DateTime.now().toString().substring(0, 19),
                            'thoi_luong': _timer.substring(0, 8),
                            'muc_do': getMucDoTiengOn(),
                            'audio': _amThanh ? audioString : '',
                            'danh_dau': _markedList,
                          };
                          final mapString = jsonEncode(map);
                          print(mapString);
                          _historyList.add(mapString);
                          // print('aaabc');
                          // print(_historyList.length);
                          // _saveHistory();
                          // setState(() {
                          //   _historyList = mapsToSave
                          //       .map((map) => jsonEncode(map))
                          //       .toList();
                          // });

                          // Lưu lại danh sách lịch sử vào SharedPreferences
                          await _saveHistory();
                          if (_isRecording) {
                            stopMeter();
                            stopRecord();
                          }
                          _latestReading = null;
                          key.currentState!.updateSpeed(
                              _hieuChinhValue.toDouble(),
                              animate: true,
                              duration: Duration(seconds: 0));
                          setState(() {
                            _minDecibel = 0.0;
                            _maxDecibel = 0.0;
                            _tbDecibel = 0.0;
                            _count = <double>[];
                            _isRecording = false;
                            chartData = getChartData();
                            _visible = false;
                            _timer = '00:00:00';
                            _loadHistory();
                          });
                          print('ccccbc +1');
                          print(_historyList.length);

                          if (_xemBanLuu) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Đang lưu chuyển sang lịch sử dữ liệu !'),
                              ),
                            );
                            // Đợi 1,2 giây trước khi chuyển trang
                            Future.delayed(Duration(microseconds: 10000), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryScreen(),
                                ),
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Đang lưu dữ liệu , nhấn lịch sửu để xem lại!'),
                              ),
                            );
                          }
                        }
                      : null,
                ),
                Expanded(child: HistoryButton())
              ],
            ),
            Column(children: [
              Visibility(
                visible: _visible,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alarm,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      'Mức dB đã vượt quá $_canhBaoDB',
                      style: Styles.body.copyWith(color: Colors.red),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _count.isNotEmpty
                        ? () {
                            final currentDb = _count.last.round().toString();
                            final time = _timer.substring(0, 8);
                            final mucDo = getMucDoTiengOn();
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('Đánh dấu'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                time,
                                                style: Styles.body.copyWith(
                                                    color: Colors.lightBlue),
                                              ),
                                              Container(
                                                width: 150,
                                                child: Text(
                                                  '${currentDb} dB | ${mucDo}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.right,
                                                  style: Styles.body.copyWith(
                                                      color: Colors.grey),
                                                ),
                                              )
                                            ],
                                          ),
                                          TextField(
                                            controller: _controller,
                                            decoration: InputDecoration(
                                                hintText: 'Note'),
                                          )
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('HỦY')),
                                        TextButton(
                                            onPressed: () {
                                              final map = Map<String, String>()
                                                ..addAll({
                                                  'note': _controller.text,
                                                  'time': time,
                                                  'muc_do': mucDo,
                                                  'decibel': currentDb,
                                                });
                                              _markedList.add(map);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Đánh dấu thành công!'),
                                              ));
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK'))
                                      ],
                                    ));
                          }
                        : null,
                    child: Container(
                        width: 80,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: _count.isNotEmpty ? null : Colors.grey,
                            ),
                            SizedBox(width: 1),
                            Text(
                              'Đánh dấu',
                              style: Styles.body.copyWith(
                                fontSize: 12,
                                color: _count.isNotEmpty ? null : Colors.grey,
                              ),
                            )
                          ],
                        )),
                  ),
                  Text(
                    _timer,
                    style: Styles.body,
                  ),
                  Container(
                    width: 80,
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.list),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: Text(
                                      'Danh sách đánh dấu',
                                      style: Styles.body,
                                    ),
                                    content: Container(
                                      height: 200,
                                      child: _markedList.isEmpty
                                          ? Container(
                                              child: Center(
                                                  child:
                                                      Text('Danh sách trống')),
                                            )
                                          : ListView.separated(
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const Divider(),
                                              itemCount: _markedList.length,
                                              itemBuilder: (context, index) {
                                                final map = _markedList[index];
                                                return Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(map['time']!,
                                                          style: Styles.body
                                                              .copyWith(
                                                                  color: Colors
                                                                      .lightBlue)),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${map['decibel']!} dB',
                                                              style:
                                                                  Styles.body,
                                                            ),
                                                            Text(map['muc_do']!,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                            Text(map['note']!,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          _controller2.text =
                                                              map['note']!;
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  DanhDauDialog(
                                                                    map: map,
                                                                    controller2:
                                                                        _controller2,
                                                                    onPressed:
                                                                        () {
                                                                      final newMap = Map<
                                                                          String,
                                                                          String>()
                                                                        ..addAll({
                                                                          'note':
                                                                              _controller2.text,
                                                                          'time':
                                                                              map['time']!,
                                                                          'muc_do':
                                                                              map['muc_do']!,
                                                                          'decibel':
                                                                              map['decibel']!,
                                                                        });
                                                                      _markedList
                                                                          .removeAt(
                                                                              index);
                                                                      setState(
                                                                        () => _markedList
                                                                            .add(newMap),
                                                                      );
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ));
                                                        },
                                                        icon: Icon(Icons.edit),
                                                      ),
                                                      IconButton(
                                                          onPressed: () {
                                                            setState(
                                                              () => _markedList
                                                                  .removeAt(
                                                                      index),
                                                            );
                                                          },
                                                          icon: Icon(
                                                              Icons.delete))
                                                    ],
                                                  ),
                                                );
                                              }),
                                    ),
                                  ),
                                ));
                      },
                    ),
                  ),
                ],
              ),
              SfCartesianChart(
                  series: <LineSeries<PointChart, int>>[
                    LineSeries<PointChart, int>(
                      onRendererCreated: (ChartSeriesController controller) {
                        _chartSeriesController = controller;
                      },
                      dataSource: chartData,
                      color: Colors.lightBlue,
                      xValueMapper: (PointChart point, _) => point.time,
                      yValueMapper: (PointChart point, _) => point.decibel,
                    )
                  ],
                  primaryXAxis: NumericAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      interval: 3,
                      title: AxisTitle(text: 'Thời gian (giây)')),
                  primaryYAxis: NumericAxis(
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                      title: AxisTitle(text: 'Decibel (dB)')))
            ])
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DanhDauDialog extends StatelessWidget {
  const DanhDauDialog(
      {super.key,
      required this.map,
      required this.controller2,
      required this.onPressed});

  final Map<String, String> map;
  final TextEditingController controller2;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Đánh dấu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                map['time']!,
                style: Styles.body.copyWith(color: Colors.lightBlue),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  '${map['decibel']!} dB | ${map['muc_do']!}',
                  overflow: TextOverflow.ellipsis,
                  style: Styles.body.copyWith(color: Colors.grey),
                ),
              )
            ],
          ),
          TextField(
            controller: controller2,
            decoration: InputDecoration(hintText: 'Note'),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('HỦY')),
        TextButton(onPressed: onPressed, child: Text('OK'))
      ],
    );
  }
}
