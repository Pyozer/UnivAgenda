import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myagenda/widgets/radio_list.dart';

class ListTileChoices extends StatefulWidget {

  final String title;
  final List<String> values;
  final ValueChanged<String> onChange;
  final String selectedValue;

  const ListTileChoices(
      {Key key, this.title, this.values, this.onChange, this.selectedValue})
      : super(key: key);

  @override
  _ListTileChoicesState createState() => new _ListTileChoicesState();
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
    if (widget.selectedValue != null && widget.values.contains(widget.selectedValue))
      setState(() {
        _selectedChoice = widget.selectedValue;
      });
    else if (widget.values.length > 0)
      setState(() {
        _selectedChoice = widget.values[0];
      });
  }

  Future<Null> _openDialog() async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text(widget.title), children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              RadioList(
                  values: widget.values,
                  selectedValue: _selectedChoice,
                  onChange: (value) {
                    setState(() {
                      _selectedChoice = value;
                    });
                    Navigator.of(context).pop();
                    widget.onChange(value);
                  })
            ])
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(widget.title),
        subtitle: Text(_selectedChoice),
        onTap: _openDialog);
  }
}
