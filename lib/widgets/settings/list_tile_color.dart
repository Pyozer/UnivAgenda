import 'dart:async';

import 'package:color_picker/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';
class ListTileColor extends StatefulWidget {
  final String title;
  final String titleDialog;
  final String description;
  final ValueChanged<Color> onChange;
  final Color defaultValue;

  const ListTileColor(
      {Key key,
      @required this.title,
      this.titleDialog,
      this.description,
      this.onChange,
      this.defaultValue})
      : super(key: key);

  @override
  _ListTileColorState createState() => _ListTileColorState();
}

class _ListTileColorState extends State<ListTileColor> {
  final double kSmallColorSize = 20.0;
  final double kBigColorSize = 30.0;

  Color _inputValue;
  Color _submitInputValue;

  @override
  void initState() {
    super.initState();
    _initSelectedValue();
  }

  @protected
  void didUpdateWidget(covariant ListTileColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initSelectedValue();
  }

  void _initSelectedValue() {
    setState(() {
      _inputValue = widget.defaultValue;
      _submitInputValue = _inputValue;
    });
  }

  void _onInputChange(value) {
    setState(() {
      _inputValue = value;
    });
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _onSubmit() {
    widget.onChange(_inputValue);
    setState(() {
      _submitInputValue = _inputValue;
    });
    _closeDialog();
  }

  Future<Null> _openDialog() async {
    setState(() {
      _inputValue = _submitInputValue;
    });

    final translate = Translations.of(context);

    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.titleDialog ?? widget.title),
            contentPadding: EdgeInsets.all(8.0),
            content: MaterialColorPicker(
              onColorChange: _onInputChange,
              selectedColor: _inputValue,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: _closeDialog,
                  child: Text(translate.get(StringKey.CANCEL).toUpperCase())),
              FlatButton(
                  onPressed: _onSubmit,
                  child: Text(translate.get(StringKey.SUBMIT).toUpperCase())),
            ],
          );
        });

    /*await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.titleDialog ?? widget.title),
            contentPadding: EdgeInsets.all(8.0),
            content: ColorPicker(
              type: MaterialType.transparency,
              onColor: _onInputChange,
              currentColor: _inputValue,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: _closeDialog,
                  child: Text(translate.get(StringKey.CANCEL).toUpperCase())),
              FlatButton(
                  onPressed: _onSubmit,
                  child: Text(translate.get(StringKey.SUBMIT).toUpperCase())),
            ],
          );
        });*/
  }

  @override
  Widget build(BuildContext context) {
    final double sizeColor =
        widget.description != null ? kBigColorSize : kSmallColorSize;

    return ListTile(
        title: ListTileTitle(widget.title),
        subtitle: widget.description != null ? Text(widget.description) : null,
        trailing: CircleColor(color: _submitInputValue, circleSize: sizeColor),
        onTap: _openDialog);
  }
}
