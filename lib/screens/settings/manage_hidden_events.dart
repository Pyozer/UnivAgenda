import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ManageHiddenEvents extends StatefulWidget {
  _ManageHiddenEventsState createState() => _ManageHiddenEventsState();
}

class _ManageHiddenEventsState extends BaseState<ManageHiddenEvents> {
  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: translation(StrKey.MANAGE_HIDDEN_EVENT),
      body: ListView.builder(
        itemCount: prefs.hiddenEvents.length,
        itemBuilder: (_, index) {
          final String hiddenEvent = prefs.hiddenEvents[index];
          return ListTile(
            title: Text(hiddenEvent),
            trailing: IconButton(
              icon: Icon(OMIcons.delete),
              onPressed: () => prefs.removeHiddenEvent(hiddenEvent, true),
            ),
          );
        },
      ),
    );
  }
}
