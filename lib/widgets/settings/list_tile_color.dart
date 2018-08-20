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
  final ValueChanged<Color> onColorChange;
  final Color defaultColor;
  final List<ColorSwatch> colors;

  const ListTileColor(
      {Key key,
      @required this.title,
      this.titleDialog,
      this.description,
      this.onColorChange,
      this.colors,
      this.defaultColor})
      : super(key: key);

  @override
  _ListTileColorState createState() => _ListTileColorState();
}

class _ListTileColorState extends State<ListTileColor> {
  final double kSmallColorSize = 30.0;
  final double kBigColorSize = 38.0;

  Color _inputColor;
  Color _submitColor;

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
      _inputColor = widget.defaultColor;
      _submitColor = _inputColor;
    });
  }

  void _onColorChange(value) {
    setState(() {
      _inputColor = value;
    });
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _onSubmit() {
    widget.onColorChange(_inputColor);
    setState(() {
      _submitColor = _inputColor;
    });
    _closeDialog();
  }

  Future<Null> _openDialog() async {
    setState(() {
      _inputColor = _submitColor;
    });

    final translate = Translations.of(context);

    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.titleDialog ?? widget.title),
            contentPadding: const EdgeInsets.all(8.0),
            content: MaterialColorPicker(
              onColorChange: _onColorChange,
              selectedColor: _inputColor,
              colors: widget.colors,
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
  }

  @override
  Widget build(BuildContext context) {
    final double sizeColor =
        widget.description != null ? kBigColorSize : kSmallColorSize;

    return ListTile(
        title: ListTileTitle(widget.title),
        subtitle: widget.description != null ? Text(widget.description) : null,
        trailing: CircleColor(color: _submitColor, circleSize: sizeColor),
        onTap: _openDialog);
  }
}
