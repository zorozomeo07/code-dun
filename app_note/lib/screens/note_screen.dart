import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:note/app_model.dart';
import 'package:note/data/data.dart';
import 'package:note/data/rest_ful_api.dart';
import 'package:note/global/styling.dart';
import 'package:note/pages/note_editing.dart';
import 'package:note/widgets/note_item.dart';
import 'package:note/widgets/transition_route.dart';
import 'package:provider/provider.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appModel = context.watch<AppModel>();
    return Padding(
      padding: EdgeInsets.all(Insets.extraLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note Kimer',
            style: TextStyles.h1,
          ),
          Text('Hãy note lại mọi thứ quan trọng'),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: MasonryGridView(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  InkWell(
                    onTap: () {
                      appModel.note = Note(
                          id: 0,
                          tieuDe: '',
                          body: '',
                          isMarked: 0,
                          size: 16,
                          style: 0,
                          weight: 0,
                          underline: 0,
                          date: DateFormat('y.M.d').format(DateTime.now()));
                      Navigator.push(context, transitionRoute(NoteEditing()));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 160,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 225, 255, 245),
                          border:
                              Border.all(width: 1, color: Colors.tealAccent),
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DottedBorder(
                            borderType: BorderType.Oval,
                            color: Colors.tealAccent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              height: 50,
                              width: 50,
                              child: Icon(
                                Icons.add,
                                color: Colors.tealAccent,
                              ),
                            ),
                          ),
                          Text(
                            'New note',
                            style: TextStyle(color: Colors.tealAccent.shade400),
                          )
                        ],
                      ),
                    ),
                  ),
                  ...appModel.noteList.map(
                    (note) {
                      return NoteItem(
                        key: Key(note.id.toString()),
                        onTap: () {
                          appModel.note = note;
                          Navigator.push(
                              context, transitionRoute(NoteEditing()));
                        },
                        onDismissed: () async {
                          deleteNote(note.id);
                          appModel.noteList = await getNoteList();
                        },
                        tieuDe: note.tieuDe,
                        isMarked: note.isMarked == 1,
                        body: note.body,
                        picture: note.picture,
                        date: note.date,
                      );
                    },
                  ),
                ],
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
              ),
            ),
          )
        ],
      ),
    );
  }
}
