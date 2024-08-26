import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'package:link_text/link_text.dart';
import 'package:note/app_model.dart';
import 'package:note/data/rest_ful_api.dart';
import 'package:note/global/my_color.dart';
import 'package:note/global/styling.dart';
import 'package:note/widgets/option_button.dart';
import 'package:provider/provider.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteEditing extends StatefulWidget {
  const NoteEditing({
    super.key,
  });

  @override
  State<NoteEditing> createState() => _NoteEditingState();
}

class _NoteEditingState extends State<NoteEditing> {
  late TextEditingController _urlController;
  late TextEditingController _bodyController;
  late TextEditingController _tieuDeController;
  late File file;
  @override
  void initState() {
    _urlController = TextEditingController();
    _bodyController = TextEditingController();
    _tieuDeController = TextEditingController();

    _bodyController.text = context.read<AppModel>().note.body;
    _tieuDeController.text = context.read<AppModel>().note.tieuDe;
    super.initState();
  }

  List<XFile>? _mediaFileList;

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
      return context.read<AppModel>().note.picture != null
          ? Image.memory(context.read<AppModel>().note.picture!)
          : Container();
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

  @override
  Widget build(BuildContext context) {
    final appModel = context.watch<AppModel>();
    final note = appModel.note;

    _urlController.text = 'http://';

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.color,
        shape: OvalBorder(),
        onPressed: () async {
          if (context.read<AppModel>().note.id == 0) {
            note.id = appModel.noteList.length;
            appModel.note = note;
            insertNote(appModel.note);
            appModel.noteList = await getNoteList();
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Thêm thành công!')));
          } else {
            updateNote(appModel.note);
            appModel.noteList = await getNoteList();
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Cập nhật thành công!')));
          }
        },
        child: Icon(
          Icons.save,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              top: Insets.large, left: Insets.large, right: Insets.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back)),
                  Text('Trở lại', style: TextStyles.h2),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
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
                                              note.picture =
                                                  await file.readAsBytes();

                                              appModel.note = note;
                                              Navigator.pop(context);
                                            },
                                            label: 'Thư viện',
                                          ),
                                          OptionButton(
                                            onPressed: () async {
                                              await _onImageButtonPressed(
                                                  ImageSource.camera,
                                                  context: context);
                                              note.picture =
                                                  await file.readAsBytes();

                                              appModel.note = note;
                                              Navigator.pop(context);
                                            },
                                            label: 'Camera',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ));
                      },
                      icon: Icon(Icons.photo_outlined)),
                  IconButton(
                    onPressed: () async {
                      note.body += 'http://';
                      _bodyController.text += 'http://';
                      appModel.note = note;
                    },
                    icon: Icon(Icons.add_link),
                  ),
                  IconButton(
                    onPressed: () {
                      if (appModel.closedFormat == true) {
                        appModel.closedFormat = false;
                      } else {
                        appModel.closedFormat = true;
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            !appModel.closedFormat == true
                                ? MyColors.color
                                : Colors.white)),
                    icon: Icon(Icons.text_fields,
                        color: !appModel.closedFormat == true
                            ? Colors.white
                            : null),
                  ),
                  IconButton(
                    onPressed: () {
                      if (note.isMarked == 0) {
                        note.isMarked = 1;
                      } else {
                        note.isMarked = 0;
                      }
                      appModel.note = note;
                    },
                    icon: Icon(
                      note.isMarked == 0
                          ? Icons.bookmark_border
                          : Icons.bookmark,
                      color: note.isMarked == 0 ? null : Colors.yellow.shade700,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _tieuDeController,
                          onChanged: (value) {
                            note.tieuDe = value;
                            appModel.note = note;
                          },
                          minLines: 1,
                          maxLines: 3,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          style: TextStyles.h1,
                          decoration: InputDecoration(
                            hintText: 'Nhập tiêu đề',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 22,
                              color: Colors.grey.shade300,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                        Text(
                          note.date,
                          style: TextStyles.h4.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Stack(children: [
                          TextField(
                            onChanged: (value) {
                              note.body = value;
                              appModel.note = note;
                            },
                            controller: _bodyController,
                            autofocus: true,
                            maxLines: null,
                            decoration: null,
                            style: TextStyle(
                              height: 1.5,
                              letterSpacing: 0,
                              color: Colors.transparent,
                              fontSize: note.size.toDouble(),
                              fontStyle:
                                  note.style == 1 ? FontStyle.italic : null,
                              fontWeight:
                                  note.weight == 1 ? FontWeight.bold : null,
                              decoration: note.underline == 1
                                  ? TextDecoration.underline
                                  : null,
                            ),
                          ),
                          TransparentPointer(
                            child: LinkText(
                              note.body,
                              textStyle: TextStyle(
                                height: 1.5,
                                letterSpacing: 0,
                                color: Colors.black,
                                fontSize: note.size.toDouble(),
                                fontStyle:
                                    note.style == 1 ? FontStyle.italic : null,
                                fontWeight:
                                    note.weight == 1 ? FontWeight.bold : null,
                                decoration: note.underline == 1
                                    ? TextDecoration.underline
                                    : null,
                              ),
                              linkStyle: TextStyle(
                                height: 1.5,
                                letterSpacing: 0,
                                color: Colors.blue,
                                fontSize: note.size.toDouble(),
                                fontStyle:
                                    note.style == 1 ? FontStyle.italic : null,
                                fontWeight:
                                    note.weight == 1 ? FontWeight.bold : null,
                                decoration: note.underline == 1
                                    ? TextDecoration.underline
                                    : null,
                              ),
                              onLinkTap: (link) async {
                                final Uri _url = Uri.parse(link);
                                await launchUrl(_url,
                                    mode: LaunchMode.externalApplication);
                              },
                            ),
                          ),
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        !kIsWeb &&
                                defaultTargetPlatform == TargetPlatform.android
                            ? FutureBuilder<void>(
                                future: retrieveLostData(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<void> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                    case ConnectionState.waiting:
                                      return Container();
                                    case ConnectionState.done:
                                      return _previewImages();
                                    case ConnectionState.active:
                                      if (snapshot.hasError) {
                                        return Text(
                                          'Pick image/video error: ${snapshot.error}}',
                                          textAlign: TextAlign.center,
                                        );
                                      } else {
                                        return Container();
                                      }
                                  }
                                },
                              )
                            : _previewImages(),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(visible: !appModel.closedFormat, child: TextFormat())
            ],
          ),
        ),
      ),
    );
  }
}

class TextFormat extends StatefulWidget {
  const TextFormat({super.key});

  @override
  State<TextFormat> createState() => _TextFormatState();
}

class _TextFormatState extends State<TextFormat> {
  double sliderValue = 1;
  @override
  Widget build(BuildContext context) {
    final appModel = context.watch<AppModel>();
    final note = appModel.note;

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(offset: Offset(0, -1), blurRadius: 2, color: Colors.grey),
        ],
      ),
      padding: EdgeInsets.all(Insets.large),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          note.style == 1 ? MyColors.color : Colors.white)),
                  icon: Icon(Icons.format_italic,
                      color: note.style == 1 ? Colors.white : null),
                  onPressed: () {
                    if (note.style == 0) {
                      note.style = 1;
                    } else {
                      note.style = 0;
                    }
                    appModel.note = note;
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          note.weight == 1 ? MyColors.color : Colors.white)),
                  icon: Icon(Icons.format_bold,
                      color: note.weight == 1 ? Colors.white : null),
                  onPressed: () {
                    if (note.weight == 0) {
                      note.weight = 1;
                    } else {
                      note.weight = 0;
                    }
                    appModel.note = note;
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          note.underline == 1 ? MyColors.color : Colors.white)),
                  icon: Icon(Icons.format_underline,
                      color: note.underline == 1 ? Colors.white : null),
                  onPressed: () {
                    if (note.underline == 0) {
                      note.underline = 1;
                    } else {
                      note.underline = 0;
                    }
                    appModel.note = note;
                  },
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    appModel.closedFormat = true;
                  },
                )
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: Row(
              children: [
                Text('Aa', style: TextStyles.h2),
                Slider(
                    max: 3,
                    value: sliderValue,
                    divisions: 3,
                    onChanged: (value) {
                      sliderValue = value;
                      if (value == 0) {
                        note.size = 16;
                      } else if (value == 1) {
                        note.size = 18;
                      } else if (value == 2) {
                        note.size = 20;
                      } else {
                        note.size = 22;
                      }
                      appModel.note = note;
                    }),
                Text('Aa', style: TextStyles.h2.copyWith(fontSize: 22))
              ],
            ),
          )
        ],
      ),
    );
  }
}
