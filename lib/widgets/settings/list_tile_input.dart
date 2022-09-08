import 'dart:async';

import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/settings/list_tile_title.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';

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
  _ListTileInputState createState() => _ListTileInputState();
}

class _ListTileInputState extends State<ListTileInput> {
  late String _inputValue;
  late String _submitInputValue;

  @override
  void initState() {
    super.initState();
    _initSelectedValue();
  }

  @protected
  void didUpdateWidget(covariant ListTileInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initSelectedValue();
  }

  void _initSelectedValue() {
    setState(() {
      _inputValue = widget.defaultValue ?? "";
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

  Future<Null> _openDialog() async {
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
