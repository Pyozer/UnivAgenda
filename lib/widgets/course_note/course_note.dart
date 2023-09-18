import 'package:flutter/material.dart';

import '../../keys/string_key.dart';
import '../../models/courses/note.dart';
import '../../utils/translations.dart';

class CourseNote extends StatelessWidget {
  final Note note;
  final ValueChanged<Note> onDelete;
  final ValueChanged<Note> onEdit;

  const CourseNote({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
              child: SelectableText(
                note.text,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => onEdit(note),
            tooltip: i18n.text(StrKey.EDIT),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => onDelete(note),
            tooltip: i18n.text(StrKey.DELETE),
          ),
        ],
      ),
    );
  }
}
