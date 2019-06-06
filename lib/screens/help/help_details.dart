import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/help_item.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/api/api.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result_help.dart';

class HelpDetailsScreen extends StatelessWidget {
  final HelpItem helpItem;

  const HelpDetailsScreen({Key key, @required this.helpItem})
      : assert(helpItem != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsProvider.setScreen(this);
    
    return AppbarPage(
      title: i18n.text(StrKey.HELP_FEEDBACK),
      body: FutureBuilder<String>(
        future: Api().getHelp(helpItem.filename),
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
      ),
    );
  }
}
