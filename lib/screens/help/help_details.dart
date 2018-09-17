import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/help_item.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/no_result_help.dart';

class HelpDetailsScreen extends StatelessWidget {
  final HelpItem helpItem;

  const HelpDetailsScreen({Key key, @required this.helpItem})
      : assert(helpItem != null),
        super(key: key);

  Future<String> _loadHelpPage() async {
    final response = await HttpRequest.get(helpItem.page);
    if (!response.isSuccess) {
      throw Exception();
    }
    return response.httpResponse.body;
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    
    return AppbarPage(
        title: translations.get(StringKey.HELP_FEEDBACK),
        body: FutureBuilder(
          future: _loadHelpPage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                data: snapshot.data,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
              );
            }

            if (snapshot.hasError) return const NoResultHelp();

            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
