import 'dart:async';

import 'package:flutter/material.dart';

import '../../keys/string_key.dart';
import '../../utils/translations.dart';
import '../ui/dialog/dialog_predefined.dart';
import 'list_tile_title.dart';

class ListTileInput extends StatefulWidget {
  final String title;
  final String? titleDialog;
  final ValueChanged<String> onChange;
  final String? defaultValue;
  final String? hintText;
  final Widget? suffix;

  const ListTileInput({
    Key? key,
    required this.title,
    this.titleDialog,
    required this.onChange,
    this.defaultValue,
    this.hintText,
    this.suffix,
  }) : super(key: key);

  @override
  ListTileInputState createState() => ListTileInputState();
}

class ListTileInputState extends State<ListTileInput> {
  late String _inputValue;
  late String _submitInputValue;

  @override
  void initState() {
    super.initState();
    _initSelectedValue();
  }

  @override
  void didUpdateWidget(covariant ListTileInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initSelectedValue();
  }

  void _initSelectedValue() {
    setState(() {
      _inputValue = widget.defaultValue ?? '';
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
      TextField(
        onChanged: _onInputChange,
        controller: TextEditingController(text: _inputValue),
        decoration: InputDecoration(hintText: widget.hintText),
        minLines: 1,
        maxLines: 10,
      ),
      i18n.text(StrKey.SUBMIT),
      i18n.text(StrKey.CANCEL),
      true,
    );

    if (isDialogPositive) _onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: ListTileTitle(widget.title),
      subtitle: Text(
        _submitInputValue.toString(),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: widget.suffix,
      onTap: _openDialog,
    );
  }
}
