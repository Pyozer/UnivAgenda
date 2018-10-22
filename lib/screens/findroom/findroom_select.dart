import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/room.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/screens/findroom/findroom_result.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/widgets/ui/treeview/node.dart';
import 'package:myagenda/widgets/ui/treeview/treeview.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class FindRoomFilter extends StatefulWidget {
  final List<String> groupKeySearch;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const FindRoomFilter({
    Key key,
    this.groupKeySearch,
    this.startTime,
    this.endTime,
  }) : super(key: key);

  FindRoomFilterState createState() => FindRoomFilterState();
}

class FindRoomFilterState extends BaseState<FindRoomFilter> {
  List<Node> _selectedResources = [];

  _onSubmit() {
    List<Room> searchResources = [];
    _selectedResources.forEach((node) {
      searchResources.add(Room(node.key, node.value));
    });

    Navigator.of(context).push(
      CustomRoute(
        builder: (context) => FindRoomResults(
              searchResources: searchResources,
              startTime: widget.startTime,
              endTime: widget.endTime,
            ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectFirst = widget.groupKeySearch[0];
    var selectSecond = widget.groupKeySearch[1];

    return AppbarPage(
      title: translations.get(StringKey.FINDROOM_RESULTS),
      actions: <Widget>[
        IconButton(
          icon: const Icon(OMIcons.check),
          onPressed: () {
            _onSubmit();
          },
        )
      ],
      body: TreeView(
        treeTitle: selectSecond,
        dataSource: prefs.resources[selectFirst][selectSecond],
        onCheckedChanged: (listNode) {
          _selectedResources = listNode;
        },
      ),
    );
  }
}
