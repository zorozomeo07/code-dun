import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:note/global/styling.dart';

class NoteItem extends StatelessWidget {
  final VoidCallback onTap;
  final String tieuDe;
  final bool isMarked;
  final String body;
  final Uint8List? picture;
  final String date;
  final VoidCallback? onDismissed;

  NoteItem(
      {super.key,
      required this.onTap,
      required this.tieuDe,
      required this.isMarked,
      required this.body,
      required this.picture,
      required this.date,
      this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: key!,
        direction: onDismissed != null
            ? DismissDirection.endToStart
            : DismissDirection.none,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 30),
          child: const Icon(
            Icons.delete,
            size: 30,
            color: Colors.white,
          ),
        ),
        onDismissed: (_) => onDismissed?.call(),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.0)),
          padding: EdgeInsets.all(Insets.large),
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tieuDe,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Visibility(
                        visible: isMarked,
                        child: Icon(
                          Icons.bookmark,
                          color: Colors.yellow.shade700,
                        ))
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  body,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 5,
                ),
                picture != null ? Image.memory(picture!) : Container(),
                SizedBox(
                  height: 5,
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ));
  }
}
