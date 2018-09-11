import 'package:flutter/material.dart';

class NoResult extends StatelessWidget {
  final Widget header;
  final Widget footer;
  final String title;
  final String text;
  final bool hasHeader;

  const NoResult(
      {Key key,
      this.header,
      this.footer,
      @required this.title,
      @required this.text,
      this.hasHeader = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget defaultHeader;
    if (header == null && hasHeader) {
      defaultHeader = Material(
        elevation: 2.0,
        shape: const CircleBorder(),
        child: Image.network(
          "https://cdn4.iconfinder.com/data/icons/reaction/32/sad-512.png",
          width: 140.0,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            header ?? defaultHeader ?? const SizedBox.shrink(),
            const SizedBox(height: 40.0),
            Text(
              title,
              style: textTheme.headline.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            Text(
              text,
              style: textTheme.subhead,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            footer ?? const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
