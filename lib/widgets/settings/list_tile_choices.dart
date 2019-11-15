import 'dart:async';

import 'package:flutter/material.dart';
import 'package:univagenda/widgets/settings/list_tile_title.dart';
import 'package:univagenda/widgets/settings/radio_list.dart';

class ListTileChoices extends StatefulWidget {
  final String title;
  final String titleDialog;
  final List<String> values;
  final ValueChanged<String> onChange;
  final String selectedValue;

  const ListTileChoices({
    Key key,
    @required this.title,
    @required this.values,
    this.titleDialog,
    this.onChange,
    this.selectedValue,
  }) : super(key: key);

  @override
  _ListTileChoicesState createState() => _ListTileChoicesState();
}

class _ListTileChoicesState extends State<ListTileChoices> {
  String _selectedChoice = "";

  @override
  void initState() {
    super.initState();
    initSelectedValue();
  }

  @protected
  void didUpdateWidget(covariant ListTileChoices oldWidget) {
    super.didUpdateWidget(oldWidget);
    initSelectedValue();
  }

  void initSelectedValue() {
    if (widget.selectedValue != null &&
        widget.values.contains(widget.selectedValue))
      setState(() => _selectedChoice = widget.selectedValue);
    else if (widget.values.isNotEmpty)
      setState(() => _selectedChoice = widget.values[0]);
  }

  void _onRadioListChange(value) {
    setState(() => _selectedChoice = value);
    Navigator.of(context).pop();
    widget.onChange(value);
  }

  Future<Null> _openDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SimpleDialog(
        title: Text(widget.titleDialog ?? widget.title),
        children: [
          RadioList(
            values: widget.values,
            selectedValue: _selectedChoice,
            onChange: _onRadioListChange,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: ListTileTitle(widget.title),
      subtitle: Text(
        _selectedChoice,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      onTap: _openDialog,
    );
  }
}
