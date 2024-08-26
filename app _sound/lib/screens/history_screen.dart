import 'dart:convert';
import 'package:do_am_thanh/screens/detail_history_screen.dart';
import 'package:do_am_thanh/styles.dart';
import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> _historyList = <String>[];
  bool _isMultiSelectMode = false;
  Set<String> _selectedItems = <String>{};

  Future<void> _saveHistory() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setStringList('history', _historyList);
  }

  Future<void> _loadHistory() async {
    final pref = await SharedPreferences.getInstance();
    final loadedHistory = pref.getStringList('history') ?? [];
    setState(() {
      _historyList = loadedHistory;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _saveHistory();
  }

  Future<void> _removeHistoryItem(String mapString) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa mục này?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _historyList.remove(mapString); // Xóa mục khỏi danh sách
      });
      // Cập nhật SharedPreferences sau khi xóa
      final pref = await SharedPreferences.getInstance();
      await pref.setStringList(
          'history', _historyList); // Cập nhật danh sách đã lưu

      // // Hiển thị thông báo đã xóa thành công
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Đã xóa thành công!'),
      //   ),
      // );
    }
  }

  Future<void> _clearHistory() async {
    bool? confirmClear = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa tất cả'),
          content: Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Xóa tất cả'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmClear == true) {
      setState(() {
        _historyList.clear(); // Xóa toàn bộ danh sách
        _selectedItems.clear(); // Xóa các mục đã chọn
      });
      final pref = await SharedPreferences.getInstance();
      await pref.remove('history'); // Xóa dữ liệu khỏi SharedPreferences
    }
  }

  Future<void> _removeSelectedItems() async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa các mục đã chọn'),
          content: Text('Bạn có chắc chắn muốn xóa các mục đã chọn?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _historyList.removeWhere((item) => _selectedItems.contains(item));
        _selectedItems.clear(); // Clear selected items
        _isMultiSelectMode = false; // Exit multi-select mode
      });

      // Cập nhật SharedPreferences sau khi xóa
      final pref = await SharedPreferences.getInstance();
      await pref.setStringList('history', _historyList);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Các mục đã chọn đã được xóa thành công!'),
        ),
      );
    }
  }

  void _toggleSelection(String mapString) {
    setState(() {
      if (_selectedItems.contains(mapString)) {
        _selectedItems.remove(mapString);
      } else {
        _selectedItems.add(mapString);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử'),
        centerTitle: true,
        actions: [
          if (_isMultiSelectMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed:
                  _selectedItems.isNotEmpty ? _removeSelectedItems : null,
            ),
          IconButton(
            icon: Icon(_isMultiSelectMode ? Icons.close : Icons.delete_forever),
            onPressed: () {
              setState(() {
                _isMultiSelectMode = !_isMultiSelectMode;
                _selectedItems.clear();
              });
            },
          ),
        ],
      ),
      body: _historyList.isNotEmpty
          ? ListView(
              padding: EdgeInsets.all(8.0),
              children: _historyList
                  .map((mapString) {
                    final map = jsonDecode(mapString);
                    return Card(
                      color: _selectedItems.contains(mapString)
                          ? Colors.blue.shade100
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _isMultiSelectMode = true;
                              _toggleSelection(mapString);
                            });
                          },
                          onTap: () {
                            if (_isMultiSelectMode) {
                              _toggleSelection(mapString);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailHistory(map: map),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        map['date_time'],
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SeparatedRow(
                                        separatorBuilder: () => SizedBox(
                                          width: 5,
                                        ),
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  map['title'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Styles.body,
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.history,
                                                      size: 15,
                                                      color: Colors.lightBlue,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                          map['thoi_luong'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .lightBlue,
                                                          )),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${map['thap_nhat']} dB',
                                                style: Styles.body,
                                              ),
                                              Text(
                                                'Thấp nhất',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${map['trung_binh']} dB',
                                                style: Styles.body,
                                              ),
                                              Text(
                                                'Trung bình',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${map['cao_nhat']} dB',
                                                style: Styles.body,
                                              ),
                                              Text(
                                                'Cao nhất',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (!_isMultiSelectMode)
                                  IconButton(
                                    onPressed: () =>
                                        _removeHistoryItem(mapString),
                                    icon: Icon(
                                      Icons.delete,
                                      size: 18,
                                    ),
                                  ),
                                if (_isMultiSelectMode)
                                  Checkbox(
                                    value: _selectedItems.contains(mapString),
                                    onChanged: (bool? selected) {
                                      _toggleSelection(mapString);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                  .toList()
                  .reversed
                  .toList(),
            )
          : Center(
              child: Text('Danh sách trống'),
            ),
    );
  }
}
