import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/models/courses/note.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:outline_material_icons_tv/outline_material_icons.dart';

typedef NoteChanged(Note note);

class CourseNote extends StatelessWidget {
  final Note note;
  final NoteChanged? onDelete;

  const CourseNote({Key? key, required this.note, this.onDelete})
      : super(key: key);

  List<Widget> _buildElements(BuildContext context) {
    List<Widget> elems = [
      Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
          child: Text(
            note.text,
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.justify,
          ),
        ),
      )
    ];

    if (onDelete != null)
      elems.add(IconButton(
        icon: const Icon(OMIcons.delete),
        onPressed: () => onDelete!(note),
        tooltip: i18n.text(StrKey.DELETE),
      ));
    return elems;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(children: _buildElements(context)),
    );
  }
}
