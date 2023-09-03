import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/screen_message/no_result.dart';

class ManageHiddenEvents extends StatefulWidget {
  const ManageHiddenEvents({Key? key}) : super(key: key);

  @override
  ManageHiddenEventsState createState() => ManageHiddenEventsState();
}

class ManageHiddenEventsState extends State<ManageHiddenEvents> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsProvider.setScreen(widget);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildRow(String hiddenEvent) {
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(hiddenEvent)),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => context
                .read<SettingsProvider>()
                .removeHiddenEvent(hiddenEvent, true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<SettingsProvider>();

    return AppbarPage(
      title: i18n.text(StrKey.HIDDEN_EVENT),
      body: prefs.hiddenEvents.isEmpty
          ? Center(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  NoResult(
                    title: i18n.text(StrKey.NO_HIDDEN_EVENT),
                    text: i18n.text(StrKey.NO_HIDDEN_EVENT_TEXT),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: prefs.hiddenEvents.length,
              itemBuilder: (_, index) => _buildRow(
                prefs.hiddenEvents[index].title,
              ),
            ),
    );
  }
}
