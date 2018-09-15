import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myagenda/models/help_item.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:http/http.dart' as http;
import 'package:myagenda/widgets/ui/no_result_help.dart';

class HelpDetailsScreen extends StatelessWidget {
  final HelpItem helpItem;

  const HelpDetailsScreen({Key key, @required this.helpItem})
      : assert(helpItem != null),
        super(key: key);

  Future<String> _loadHelpPage() async {
    final response = await http.get(helpItem.page);
    if (response.statusCode != 200 || response.body.isEmpty) {
      throw Exception();
    }
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
        title: helpItem.title,
        body: FutureBuilder(
          future: _loadHelpPage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                data: snapshot.data,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
              );
            }

            if (snapshot.hasError)
              return const NoResultHelp();

            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
