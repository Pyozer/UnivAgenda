import 'package:flutter/material.dart';
import 'package:myagenda/widgets/list_tile_title.dart';

class ListTileSwitch extends StatefulWidget {
  final String title;
  final String description;
  final ValueChanged<bool> onChange;
  final bool defaultValue;

  const ListTileSwitch(
      {Key key,
      @required this.title,
      this.description,
      this.onChange,
      this.defaultValue})
      : super(key: key);

  @override
  _ListTileSwitchState createState() => new _ListTileSwitchState();
}

class _ListTileSwitchState extends State<ListTileSwitch> {
  bool _switchValue = false;

  @override
  void initState() {
    super.initState();
    _updateSelectedValue(widget.defaultValue);
  }

  @protected
  void didUpdateWidget(covariant ListTileSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(widget.defaultValue);
    _updateSelectedValue(widget.defaultValue);
  }

  void _updateSelectedValue(bool value) {
    setState(() {
      _switchValue = widget.defaultValue ?? false;
    });
  }

  void _onSwitchChange(value) {
    _updateSelectedValue(value);
    widget.onChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: ListTileTitle(widget.title),
        subtitle: widget.description != null ? Text(widget.description) : null,
        trailing: Switch(value: _switchValue, onChanged: _onSwitchChange),
        onTap: () {
          _onSwitchChange(!_switchValue);
        });
  }
}
