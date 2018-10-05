import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';

class ListTileColor extends StatefulWidget {
  final String title;
  final String titleDialog;
  final String description;
  final ValueChanged<Color> onColorChange;
  final Color selectedColor;
  final List<ColorSwatch> colors;

  const ListTileColor(
      {Key key,
      @required this.title,
      this.titleDialog,
      this.description,
      this.onColorChange,
      this.colors,
      this.selectedColor})
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
    // Specified color OR 1st color of specified colors OR 1st material color
    _inputColor = widget.selectedColor ??
        ((widget.colors != null) ? widget.colors[0] : null) ??
        materialColors[0];
    _submitColor = _inputColor;
  }

  void _onColorChange(value) {
    setState(() {
      _inputColor = value;
    });
  }

  void _onSubmit() {
    widget.onColorChange(_inputColor);
    setState(() {
      _submitColor = _inputColor;
    });
  }

  Future<Null> _openDialog() async {
    setState(() {
      _inputColor = _submitColor;
    });

    final translate = Translations.of(context);

    var colorPicker = MaterialColorPicker(
      onColorChange: _onColorChange,
      selectedColor: _inputColor,
      colors: widget.colors,
    );

    bool isDialogPositive = await DialogPredefined.showContentDialog(
      context,
      widget.titleDialog ?? widget.title,
      colorPicker,
      translate.get(StringKey.SUBMIT),
      translate.get(StringKey.CANCEL),
      true,
      const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0)
    );

    if (isDialogPositive) _onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final sizeColor =
        widget.description != null ? kBigColorSize : kSmallColorSize;

    return ListTile(
      title: ListTileTitle(widget.title),
      subtitle: Text(widget.description ?? ""),
      trailing: CircleColor(color: _submitColor, circleSize: sizeColor),
      onTap: _openDialog,
    );
  }
}
