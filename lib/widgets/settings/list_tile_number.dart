import 'dart:async';

import 'package:flutter/material.dart';

import '../../keys/string_key.dart';
import '../../utils/translations.dart';
import '../ui/dialog/dialog_predefined.dart';
import '../ui/number_selector.dart';
import 'list_tile_title.dart';

class ListTileNumber extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? titleDialog;
  final ValueChanged<int> onChange;
  final int? defaultValue;
  final int minValue;
  final int maxValue;

  const ListTileNumber({
    Key? key,
    required this.title,
    this.subtitle,
    this.titleDialog,
    required this.onChange,
    this.defaultValue,
    this.minValue = 0,
    required this.maxValue,
  })  : assert(maxValue > minValue),
        super(key: key);

  @override
  ListTileNumberState createState() => ListTileNumberState();
}

class ListTileNumberState extends State<ListTileNumber> {
  late int _inputValue;
  late int _submitInputValue;

  @override
  void initState() {
    super.initState();
    _initSelectedValue();
  }

  @override
  void didUpdateWidget(covariant ListTileNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initSelectedValue();
  }

  void _initSelectedValue() {
    setState(() {
      _inputValue = widget.defaultValue ?? widget.minValue;
      _submitInputValue = _inputValue;
    });
  }

  void _onInputChange(value) {
    setState(() => _inputValue = value);
  }

  void _onSubmit() {
    widget.onChange(_inputValue);
    setState(() => _submitInputValue = _inputValue);
  }

  Future<void> _openDialog() async {
    setState(() => _inputValue = _submitInputValue);

    bool isDialogPositive = await DialogPredefined.showContentDialog(
        context,
        widget.titleDialog ?? widget.title,
        NumberSelector(
          min: widget.minValue,
          max: widget.maxValue,
          initialValue: _inputValue,
          onChanged: _onInputChange,
        ),
        i18n.text(StrKey.SUBMIT),
        i18n.text(StrKey.CANCEL),
        true,
        const EdgeInsets.all(0.0));

    if (isDialogPositive) _onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: ListTileTitle(widget.title),
      subtitle: Text(widget.subtitle ?? _submitInputValue.toString()),
      onTap: _openDialog,
    );
  }
}
