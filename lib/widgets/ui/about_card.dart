import 'package:flutter/material.dart';

const kPadding = 18.0;
const kMargin = EdgeInsets.all(16.0);

class AboutCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool lateralPadding;
  final EdgeInsets margin;

  const AboutCard({
    Key key,
    @required this.title,
    this.children,
    this.lateralPadding = true,
    this.margin = kMargin,
  }) : super(key: key);

  List<Widget> _buildChildren(BuildContext context) {
    final List<Widget> cardContent = [];
    cardContent.add(
      Padding(
        padding: lateralPadding
            ? const EdgeInsets.only(bottom: 12.0)
            : const EdgeInsets.fromLTRB(kPadding, 0.0, kPadding, 8.0),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .title
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
    cardContent.addAll(children ?? []);

    return cardContent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: margin,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
      ),
      child: Container(
        padding: lateralPadding
            ? const EdgeInsets.all(kPadding)
            : const EdgeInsets.symmetric(vertical: kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildChildren(context),
        ),
      ),
    );
  }
}
