import 'package:flutter/material.dart';

class AddNoteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddNoteButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Ajouter traduction "Add Note"
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: OutlineButton(child: Text('ADD NOTE'), onPressed: onPressed));
  }
}
