import 'package:flutter/material.dart';

class AboutCard extends StatelessWidget {
  static const kPadding = 16.0;

  final String title;
  final List<Widget> children;
  final bool lateralPadding;

  const AboutCard(
      {Key key,
      @required this.title,
      this.children,
      this.lateralPadding = true})
      : super(key: key);

  List<Widget> _buildChildren(BuildContext context) {
    final List<Widget> cardContent = [];
    cardContent.add(Padding(
        padding: lateralPadding
            ? const EdgeInsets.only(bottom: 8.0)
            : const EdgeInsets.fromLTRB(kPadding, 0.0, kPadding, 8.0),
        child: Text(title,
            style: Theme
                .of(context)
                .textTheme
                .title
                .copyWith(fontWeight: FontWeight.w700))));
    cardContent.addAll(children);

    return cardContent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(16.0),
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(const Radius.circular(6.0))),
        child: Container(
            padding: lateralPadding
                ? const EdgeInsets.all(kPadding)
                : const EdgeInsets.symmetric(vertical: kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildChildren(context),
            )));
  }
}
