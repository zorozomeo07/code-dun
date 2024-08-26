import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:do_am_thanh/styles.dart';
import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';

typedef Fn = void Function();

class DetailHistory extends StatefulWidget {
  const DetailHistory({super.key, required this.map});
  final Map<String, dynamic> map;
  @override
  State<DetailHistory> createState() => _DetailHistoryState();
}

class _DetailHistoryState extends State<DetailHistory> {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  Uint8List? _boumData;
  Duration _duration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.map['audio']! != '') {
      _duration = Duration(
          hours: int.parse(widget.map['thoi_luong']!.substring(0, 2)),
          minutes: int.parse(widget.map['thoi_luong']!.substring(3, 5)),
          seconds: int.parse(widget.map['thoi_luong']!.substring(6, 8)));
      init().then((value) {
        setState(() {
          _mPlayerIsInited = true;
        });
      });
    }
  }

  @override
  void dispose() {
    stopPlayer(_mPlayer);
    _mPlayer.closePlayer();
    _timer?.cancel(); // Hủy bỏ Timer khi thoát khỏi màn hình
    super.dispose();
  }

  Future<void> init() async {
    await _mPlayer.openPlayer();
    _boumData = base64.decode(widget.map['audio']!);
  }

  void play(FlutterSoundPlayer? player) async {
    _timer?.cancel(); // Hủy bỏ bất kỳ Timer nào đang chạy
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_duration == Duration.zero) {
          setState(() {
            _duration = Duration(
                hours: int.parse(widget.map['thoi_luong']!.substring(0, 2)),
                minutes: int.parse(widget.map['thoi_luong']!.substring(3, 5)),
                seconds: int.parse(widget.map['thoi_luong']!.substring(6, 8)));
          });
          timer.cancel();
        } else {
          setState(() {
            _duration -= Duration(seconds: 1);
          });
        }
      }
    });

    await player!.startPlayer(
      fromDataBuffer: _boumData,
      codec: Codec.aacADTS,
      whenFinished: () {
        setState(() {});
      },
    );
    setState(() {});
  }

  Future<void> stopPlayer(FlutterSoundPlayer player) async {
    _timer?.cancel(); // Hủy bỏ Timer khi dừng phát
    if (player.isPlaying) {
      await player.stopPlayer();
    }
    setState(() {
      _duration = Duration(
        hours: int.parse(widget.map['thoi_luong']!.substring(0, 2)),
        minutes: int.parse(widget.map['thoi_luong']!.substring(3, 5)),
        seconds: int.parse(widget.map['thoi_luong']!.substring(6, 8)),
      );
    });
  }

  Fn? getPlaybackFn(FlutterSoundPlayer? player) {
    if (!_mPlayerIsInited) {
      return null;
    }
    return player!.isStopped
        ? () {
            play(player);
          }
        : () {
            stopPlayer(player).then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> danhDaus = widget.map['danh_dau'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.map['title']!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                  child: SeparatedColumn(
                    separatorBuilder: () => SizedBox(height: 5),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Thấp nhất',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.map['thap_nhat']!,
                                style: Styles.body,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Trung bình',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.map['trung_binh']!,
                                style: Styles.body,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Cao nhất',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.map['cao_nhat']!,
                                style: Styles.body,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thời gian',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.map['date_time']!,
                            style: Styles.body,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thời lượng',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.map['thoi_luong']!,
                            style: Styles.body,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mô tả Decibel',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.map['muc_do']!,
                            style: Styles.body,
                          ),
                        ],
                      ),
                      widget.map['audio']! != ''
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: getPlaybackFn(_mPlayer),
                                  child: Text(
                                    _mPlayer.isPlaying
                                        ? 'Stop record'
                                        : 'Play record',
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  _duration
                                      .toString()
                                      .padLeft(15, '0')
                                      .substring(0, 8),
                                  style: Styles.body,
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              danhDaus.isEmpty
                  ? Container()
                  : Card(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(color: Colors.white),
                        child: SeparatedColumn(
                          separatorBuilder: () => Divider(),
                          children: [
                            Text('Danh sách đánh dấu'),
                            ...danhDaus
                                .map(
                                  (danhDauMap) => Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            danhDauMap['time']!,
                                            style: Styles.body.copyWith(
                                              color: Colors.lightBlue,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${danhDauMap['decibel']!} dB',
                                                  style: Styles.body,
                                                ),
                                                Visibility(
                                                  visible:
                                                      danhDauMap['note']! !=
                                                          null,
                                                  child: Text(
                                                    danhDauMap['note']!,
                                                    style: Styles.body.copyWith(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            danhDauMap['muc_do']!,
                                            style: Styles.body.copyWith(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
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
