import 'package:flutter/material.dart';

class Event extends StatelessWidget {
  final String title;
  final Color color;

  const Event({Key key, this.title, @required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(top: 2.0),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: title != null
          ? Text(
              title,
              maxLines: 1,
              style: const TextStyle(fontSize: 10.0, color: Colors.white),
            )
          : const SizedBox(height: 3),
    );
  }
}
