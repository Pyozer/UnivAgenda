import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import '../../keys/string_key.dart';
import '../../utils/list_colors.dart';
import '../../utils/translations.dart';
import 'list_tile_title.dart';
import '../ui/dialog/dialog_predefined.dart';

const kSmallColorSize = 30.0;
const kBigColorSize = 38.0;

class ListTileColor extends StatefulWidget {
  final String title;
  final String? titleDialog;
  final String? description;
  final ValueChanged<Color> onColorChange;
  final Color? selectedColor;
  final List<ColorSwatch>? colors;

  const ListTileColor({
    Key? key,
    required this.title,
    this.titleDialog,
    this.description,
    required this.onColorChange,
    this.colors,
    this.selectedColor,
  }) : super(key: key);

  @override
  ListTileColorState createState() => ListTileColorState();
}

class ListTileColorState extends State<ListTileColor> {
  late Color _inputColor;
  late Color _submitColor;

  @override
  void initState() {
    super.initState();
    _initSelectedValue();
  }

  @override
  void didUpdateWidget(covariant ListTileColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initSelectedValue();
  }

  void _initSelectedValue() {
    // Specified color OR 1st color of specified colors OR 1st material color
    _inputColor = widget.selectedColor ??
        ((widget.colors != null) ? widget.colors![0] : null) ??
        appMaterialColors[0];
    _submitColor = _inputColor;
  }

  void _onColorChange(value) {
    setState(() => _inputColor = value);
  }

  void _onSubmit() {
    widget.onColorChange(_inputColor);
    setState(() => _submitColor = _inputColor);
  }

  Future<void> _openDialog() async {
    setState(() => _inputColor = _submitColor);

    final colorPicker = MaterialColorPicker(
      onColorChange: _onColorChange,
      selectedColor: _inputColor,
      colors: widget.colors ?? appMaterialColors,
    );

    bool isDialogPositive = await DialogPredefined.showContentDialog(
      context,
      widget.titleDialog ?? widget.title,
      SizedBox(
        height: 215,
        child: Align(alignment: Alignment.topCenter, child: colorPicker),
      ),
      i18n.text(StrKey.SUBMIT),
      i18n.text(StrKey.CANCEL),
      true,
    );

    if (isDialogPositive) _onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final sizeColor =
        widget.description != null ? kBigColorSize : kSmallColorSize;

    return ListTile(
      title: ListTileTitle(widget.title),
      subtitle: Text(widget.description ?? ''),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CircleColor(color: _submitColor, circleSize: sizeColor),
      ),
      onTap: _openDialog,
    );
  }
}
