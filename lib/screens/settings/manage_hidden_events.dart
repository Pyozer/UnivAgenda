import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/screens/base_state.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:univagenda/widgets/ui/screen_message/no_result.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ManageHiddenEvents extends StatefulWidget {
  _ManageHiddenEventsState createState() => _ManageHiddenEventsState();
}

class _ManageHiddenEventsState extends BaseState<ManageHiddenEvents> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    AnalyticsProvider.setScreen(widget);
  }

  void _addNewFilter() async {
    bool isSubmit = await DialogPredefined.showContentDialog(
      context,
      i18n.text(StrKey.ADD_HIDDEN_EVENT),
      TextField(
        controller: _textController,
        maxLines: null,
        keyboardType: TextInputType.text,
        maxLength: 100,
        decoration: InputDecoration.collapsed(
          hintText: i18n.text(StrKey.ADD_HIDDEN_EVENT),
        ),
      ),
      i18n.text(StrKey.ADD),
      i18n.text(StrKey.CANCEL),
    );

    if (isSubmit == true) {
      final String filter = _textController.text.trim();
      if (filter.isEmpty) {
        _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: Text(i18n.text(StrKey.REQUIRE_FIELD)),
          action: SnackBarAction(
            label: i18n.text(StrKey.RETRY),
            onPressed: _addNewFilter,
          ),
        ));
      } else {
        prefs.addHiddenEvent(filter, true);
      }
    }
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
            icon: const Icon(OMIcons.delete),
            onPressed: () => prefs.removeHiddenEvent(hiddenEvent, true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      scaffoldKey: _scaffoldKey,
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
              itemBuilder: (_, index) => _buildRow(prefs.hiddenEvents[index]),
            ),
      fab: FloatingActionButton(
        child: const Icon(OMIcons.add),
        onPressed: _addNewFilter,
        heroTag: "add_filter",
      ),
    );
  }
}
