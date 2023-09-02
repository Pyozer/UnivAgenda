import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/utils/translations.dart';

class EmptyDay extends StatelessWidget {
  final EdgeInsets? padding;

  const EmptyDay({Key? key, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
      child: Text(
        i18n.text(StrKey.NO_EVENTS),
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.justify,
      ),
    );
  }
}
