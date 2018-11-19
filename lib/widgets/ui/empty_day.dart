import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/string_key.dart';

class EmptyDay extends StatelessWidget {
  final EdgeInsets padding;

  const EmptyDay({Key key, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        FlutterI18n.translate(context, StrKey.NO_EVENTS),
        style: Theme.of(context).textTheme.subhead,
        textAlign: TextAlign.justify,
      ),
    );
  }
}
