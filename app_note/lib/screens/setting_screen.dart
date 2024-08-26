import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note/global/my_color.dart';
import 'package:note/global/styling.dart';
import 'package:note/widgets/option_button.dart';
import 'package:mime/mime.dart';

enum Option { HOME_SCREEN, LOCK_SCREEN, BOTH_SCREENS }

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<XFile>? _mediaFileList;
  late File file;

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
        );
        setState(() {
          _setImageFileListFromFile(pickedFile);
          file = File(_mediaFileList![0].path);
          Navigator.pop(context);
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
      ;
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_mediaFileList != null) {
      return Semantics(
          label: 'image_picker_example_picked_images',
          child: Column(key: UniqueKey(), children: [
            ...List.generate(_mediaFileList!.length, (index) {
              final String? mime = lookupMimeType(_mediaFileList![index].path);

              return Semantics(
                  label: 'image_picker_example_picked_image',
                  child: kIsWeb
                      ? Image.network(_mediaFileList![index].path)
                      : (mime == null || mime.startsWith('image/')
                          ? Image.file(
                              File(_mediaFileList![index].path),
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return const Center(
                                    child: Text(
                                        'This image type is not supported'));
                              },
                              height: 300,
                              width: double.infinity,
                            )
                          : null));
            })
          ]));
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Container();
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _mediaFileList = response.files;
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Future<void> setWallpaper(Option option) async {
    int location;
    try {
      switch (option) {
        case Option.HOME_SCREEN:
          location = WallpaperManager.HOME_SCREEN;
          break;
        case Option.LOCK_SCREEN:
          location = WallpaperManager.LOCK_SCREEN;
          break;
        case Option.BOTH_SCREENS:
          location = WallpaperManager.BOTH_SCREEN;
          break;
      }

      await WallpaperManager.setWallpaperFromFile(file.path, location);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Thành công!'),
      ));
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text(
              'About Application',
              style: TextStyles.h3,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Thay đổi nền điện thoại',
                  style: TextStyles.h3,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await showModalBottomSheet(
                      context: context,
                      builder: (context) => BottomSheet(
                            onClosing: () {},
                            builder: (context) {
                              return Container(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OptionButton(
                                      onPressed: () async {
                                        await _onImageButtonPressed(
                                            ImageSource.gallery,
                                            context: context);
                                      },
                                      label: 'Thư viện',
                                    ),
                                    OptionButton(
                                      onPressed: () {
                                        _onImageButtonPressed(
                                            ImageSource.camera,
                                            context: context);
                                      },
                                      label: 'Camera',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ));

                  showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                              child: Container(
                            padding: EdgeInsets.all(Insets.large),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Đặt làm nền",
                                    style: TextStyles.h3,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  !kIsWeb &&
                                          defaultTargetPlatform ==
                                              TargetPlatform.android
                                      ? SingleChildScrollView(
                                          child: Container(
                                            height: 300,
                                            child: FutureBuilder<void>(
                                              future: retrieveLostData(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<void>
                                                      snapshot) {
                                                switch (
                                                    snapshot.connectionState) {
                                                  case ConnectionState.none:
                                                  case ConnectionState.waiting:
                                                    return Container();
                                                  case ConnectionState.done:
                                                    return _previewImages();
                                                  case ConnectionState.active:
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                        '',
                                                        textAlign:
                                                            TextAlign.center,
                                                      );
                                                    } else {
                                                      return Container();
                                                    }
                                                }
                                              },
                                            ),
                                          ),
                                        )
                                      : _previewImages(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                    child: Text('Màn hình khóa'),
                                    onPressed: () {
                                      setWallpaper(Option.LOCK_SCREEN);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text('Màn hình chính'),
                                    onPressed: () {
                                      setWallpaper(Option.HOME_SCREEN);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text('Cả hai màn hình'),
                                    onPressed: () {
                                      setWallpaper(Option.BOTH_SCREENS);
                                      Navigator.pop(context);
                                    },
                                  )
                                ]),
                          )));
                },
                child: Text('Chọn ảnh'),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Note',
                  style: TextStyles.h3,
                ),
              ),
              SettingList(
                title: 'Chính Sách Bảo Mật',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text('Chính sách bảo mật',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                              leading: IconButton(
                                iconSize: 25,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios_rounded,
                                ),
                              ),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '''1. Giới thiệu: Ứng dụng ghi chú của chúng tôi giúp bạn lưu trữ và quản lý các ghi chú cá nhân một cách an toàn và thuận tiện.
      2. Thông tin thu thập: Chúng tôi thu thập thông tin cơ bản như ngôn ngữ mà bạn sử dụng, nội dung ghi chú, thời gian tạo và cập nhật ghi chú.
      3. Cách sử dụng thông tin: Thông tin thu thập được sử dụng để cung cấp và cải thiện dịch vụ, cung cấp hỗ trợ kỹ thuật và giao tiếp với bạn.
      4. Chia sẻ thông tin: Chúng tôi không chia sẻ thông tin cá nhân của bạn với bên thứ ba trừ khi có sự đồng ý của bạn hoặc theo yêu cầu của pháp luật.
      5. Bảo mật thông tin: Chúng tôi sử dụng các biện pháp bảo mật kỹ thuật và tổ chức để bảo vệ thông tin cá nhân của bạn khỏi truy cập, sử dụng hoặc tiết lộ không hợp pháp.
      6. Quyền của người dùng: Bạn có quyền truy cập, cập nhật, quản lý, xuất và xóa thông tin của mình.
      7. Cập nhật chính sách: Chúng tôi sẽ thông báo cho bạn về bất kỳ thay đổi đáng kể nào trong chính sách bảo mật này.
      ''',
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Version: 0.1.0',
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ),
                            )))),
                iconData: Icons.newspaper,
              ),
              SettingList(
                title: 'Giới Thiệu',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text('Giới Thiệu',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                              leading: IconButton(
                                iconSize: 25,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios_rounded,
                                ),
                              ),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Chào mừng bạn đến với ứng dụng Note - một công cụ không thể thiếu cho cuộc sống hàng ngày của bạn.\n   Note là ứng dụng giúp bạn ghi chú và đặt báo thức một cách dễ dàng và tiện lợi.\n   Với chức năng ghi chú, bạn có thể lưu lại mọi suy nghĩ, ý tưởng hay công việc cần làm một cách nhanh chóng. Bạn cũng có thể sắp xếp các ghi chú theo thời gian hoặc theo chủ đề, giúp bạn dễ dàng tìm kiếm và xem lại.\n   Chức năng báo thức giúp bạn không bao giờ quên các cuộc hẹn quan trọng. Bạn có thể đặt báo thức theo thời gian cụ thể hoặc lặp lại hàng ngày, hàng tuần. Hơn nữa, bạn còn có thể kết hợp báo thức với ghi chú, để nhắc nhở mình về công việc cần làm khi báo thức kêu.',
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Version: 0.1.0',
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ),
                            )))),
                iconData: Icons.contact_page_outlined,
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Mẹo',
                  style: TextStyles.h3,
                ),
              ),
              ListTile(
                title: Text('Vuốt để xóa các mục'),
              ),
              Image.asset('images/vuot_xoa.jpg', height: 150, width: 150),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingList extends StatelessWidget {
  const SettingList({
    super.key,
    required this.title,
    required this.onTap,
    required this.iconData,
    this.version,
    this.switchWidget,
  });

  final String title;
  final VoidCallback onTap;
  final IconData iconData;
  final String? version;
  final Widget? switchWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        enabled: true,
        onTap: onTap,
        leading: Icon(iconData, color: MyColors.color),
        title: Text(title),
        trailing: switchWidget ?? null,
      ),
    );
  }
}
