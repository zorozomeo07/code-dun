import 'package:do_am_thanh/styles.dart';
import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _amThanh = true;
  bool _manHinhBat = true;
  bool _xemBanLuu = true;
  int _canhBaoDB = 90;

  @override
  void initState() {
    _loadAmThanh();
    _loadCanhBao();
    _loadManHinhBat();
    _loadXemBanLuu();
    super.initState();
  }

  Future<void> _saveCanhBao() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setInt('canh_bao', _canhBaoDB);
    });
  }

  Future<void> _loadCanhBao() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _canhBaoDB = pref.getInt('canh_bao') ?? 90;
    });
  }

  Future<void> _saveAmThanh() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setBool('am_thanh', _amThanh);
    });
  }

  Future<void> _loadAmThanh() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _amThanh = pref.getBool('am_thanh') ?? true;
    });
  }

  Future<void> _saveManHinhBat() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setBool('man_hinh_bat', _manHinhBat);
    });
  }

  Future<void> _loadManHinhBat() async {
    final pref = await SharedPreferences.getInstance();
    _manHinhBat = pref.getBool('man_hinh_bat') ?? true;
  }

  Future<void> _saveXemBanLuu() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setBool('xem_ban_luu', _xemBanLuu);
    });
  }

  Future<void> _loadXemBanLuu() async {
    final pref = await SharedPreferences.getInstance();
    _xemBanLuu = pref.getBool('xem_ban_luu') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: SeparatedColumn(
        separatorBuilder: () => Divider(),
        padding: EdgeInsets.all(8.0),
        children: [
          ListTile(
            title: Text(
              'Lưu tệp âm thanh',
              style: Styles.body,
            ),
            subtitle: Text('Thời gian ghi tối đa là 1 giờ'),
            trailing: Switch(
              onChanged: (value) {
                _amThanh = !_amThanh;
                _saveAmThanh();
              },
              value: _amThanh,
            ),
          ),
          ListTile(
            title: Text(
              'Giữ màn hình bật',
              style: Styles.body,
            ),
            subtitle: Text('Luôn bật màn hình khi ở trên màn hình chính'),
            trailing: Switch(
              onChanged: (value) {
                _manHinhBat = !_manHinhBat;
                if (_manHinhBat == false) {
                  KeepScreenOn.turnOff();
                } else {
                  KeepScreenOn.turnOn();
                }
                _saveManHinhBat();
              },
              value: _manHinhBat,
            ),
          ),
          ListTile(
            title: Text(
              'Cảnh báo Db',
              style: Styles.body,
            ),
            subtitle: Text('Đặt giá trị dB cho cảnh báo'),
            trailing: Text(
              '$_canhBaoDB dB',
              style: Styles.body,
            ),
            onTap: () => showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_canhBaoDB dB',
                        style: Styles.body,
                      ),
                      Row(
                        children: [
                          Text(
                            '0',
                            style: Styles.body,
                          ),
                          Slider(
                              divisions: 100,
                              value: _canhBaoDB.toDouble(),
                              min: 0,
                              max: 120,
                              onChangeEnd: (value) => _saveCanhBao(),
                              onChanged: (value) {
                                setState(() => _canhBaoDB = value.round());
                              }),
                          Text(
                            '120',
                            style: Styles.body,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Xem bản ghi sau khi lưu',
              style: Styles.body,
            ),
            subtitle: Text('Vào trang lịch sử để xem bản ghi ngay sau khi lưu'),
            trailing: Switch(
              onChanged: (value) {
                _xemBanLuu = !_xemBanLuu;
                _saveXemBanLuu();
              },
              value: _xemBanLuu,
            ),
          ),
        ],
      ),
    );
  }
}
