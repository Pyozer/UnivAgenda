import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/translate/string_key.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/list_tile_title.dart';

class ListTileInput extends StatefulWidget {
  final String title;
  final String titleDialog;
  final ValueChanged<String> onChange;
  final String defaultValue;
  final TextInputType inputType;

  const ListTileInput(
      {Key key,
      @required this.title,
      this.titleDialog,
      this.onChange,
      this.defaultValue,
      this.inputType})
      : super(key: key);

  @override
  _ListTileInputState createState() => new _ListTileInputState();
}

class _ListTileInputState extends State<ListTileInput> {
  String _inputValue = "";
  String _submitInputValue = "";

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
      _inputValue = widget.defaultValue ?? '';
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
            content: TextField(
              controller: TextEditingController(text: _inputValue),
              keyboardType: widget.inputType ?? TextInputType.text,
              onChanged: _onInputChange,
              onSubmitted: (value) {
                _onSubmit();
              },
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: _closeDialog,
                  child: Text(translate.get(StringKey.CANCEL))),
              FlatButton(
                  onPressed: _onSubmit,
                  child: Text(translate.get(StringKey.SUBMIT))),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: ListTileTitle(widget.title),
        subtitle: Text(_submitInputValue),
        onTap: _openDialog);
  }
}
