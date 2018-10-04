import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class CourseNote extends StatelessWidget {
  final Note note;
  final Function(Note note) onDelete;

  const CourseNote({Key key, @required this.note, this.onDelete})
      : super(key: key);

  List<Widget> _buildElements(BuildContext context) {
    List<Widget> elems = [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            note.text,
            style: Theme.of(context).textTheme.body1,
            textAlign: TextAlign.justify,
          ),
        ),
      )
    ];

    if (onDelete != null) {
      elems.add(Container(color: Colors.grey, height: 18.0, width: 1.0));
      elems.add(
        IconButton(
          icon: Icon(OMIcons.delete),
          onPressed: () => onDelete(note),
          tooltip: Translations.of(context).get(StringKey.DELETE),
        ),
      );
    }
    return elems;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(
        children: _buildElements(context),
      ),
    );
  }
}
