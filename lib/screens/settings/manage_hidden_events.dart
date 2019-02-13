import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ManageHiddenEvents extends StatefulWidget {
  _ManageHiddenEventsState createState() => _ManageHiddenEventsState();
}

class _ManageHiddenEventsState extends BaseState<ManageHiddenEvents> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void _addNewFilter() async {
    bool isSubmit = await DialogPredefined.showContentDialog(
      context,
      translations.text(StrKey.ADD_HIDDEN_EVENT),
      TextField(
        controller: _textController,
        maxLines: null,
        keyboardType: TextInputType.text,
        maxLength: 100,
        decoration: InputDecoration.collapsed(
          hintText: translations.text(StrKey.ADD_HIDDEN_EVENT),
        ),
      ),
      translations.text(StrKey.ADD),
      translations.text(StrKey.CANCEL),
    );

    if (isSubmit == true) {
      final String filter = _textController.text.trim();
      if (filter.isEmpty) {
        _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: Text(translations.text(StrKey.REQUIRE_FIELD)),
          action: SnackBarAction(
            label: translations.text(StrKey.RETRY),
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
            icon: Icon(OMIcons.delete),
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
      title: translations.text(StrKey.HIDDEN_EVENT),
      body: prefs.hiddenEvents.length == 0
          ? Center(
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  NoResult(
                    title: translations.text(StrKey.NO_HIDDEN_EVENT),
                    text: translations.text(StrKey.NO_HIDDEN_EVENT_TEXT),
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
