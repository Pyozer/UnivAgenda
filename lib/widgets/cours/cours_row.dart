import 'package:flutter/material.dart';
import 'package:myagenda/models/cours.dart';

class CoursRow extends StatelessWidget {
  final Cours cours;

  const CoursRow({Key key, this.cours}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color bgColorRow;
    if (cours.isExam()) bgColorRow = Colors.red[600];

    final titleStyle = textTheme.title.copyWith(fontSize: 16.0);
    final subheadStyle = textTheme.subhead.copyWith(fontSize: 14.0);
    final cationStyle =
        textTheme.caption.copyWith(fontSize: 14.0, fontWeight: FontWeight.w500);

    return InkWell(
        onTap: () {
          // TODO : Faire page d'un cours
        },
        child: Container(
            color: bgColorRow,
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cours.title, style: titleStyle),
              Text('${cours.location} - ${cours.description}',
                  style: subheadStyle),
              Text(cours.dateForDisplay(), style: cationStyle),
            ])));
  }
}
