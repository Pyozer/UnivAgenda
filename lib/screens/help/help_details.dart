import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../keys/string_key.dart';
import '../../models/help/help_item.dart';
import '../../utils/analytics.dart';
import '../../utils/api/api.dart';
import '../../utils/translations.dart';
import '../../widgets/ui/screen_message/no_result_help.dart';
import '../appbar_screen.dart';

class HelpDetailsScreen extends StatelessWidget {
  final HelpItem helpItem;

  const HelpDetailsScreen({Key? key, required this.helpItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsProvider.setScreen(this);

    return AppbarPage(
      title: i18n.text(StrKey.HELP_FEEDBACK),
      body: FutureBuilder<String>(
        future: Api().getHelp(helpItem),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data!,
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
