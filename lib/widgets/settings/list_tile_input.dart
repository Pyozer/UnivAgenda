import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';

class ListTileInput extends StatefulWidget {
  final String title;
  final String titleDialog;
  final ValueChanged<String> onChange;
  final String defaultValue;
  final TextInputType inputType;
  final String hintText;

  const ListTileInput(
      {Key key,
      @required this.title,
      this.titleDialog,
      this.onChange,
      this.defaultValue,
      this.inputType,
      this.hintText})
      : assert(title != null),
        super(key: key);

  @override
  _ListTileInputState createState() => _ListTileInputState();
}

class _ListTileInputState extends BaseState<ListTileInput> {
  String _inputValue;
  String _submitInputValue;

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
    setState(() {
      _inputValue = value;
    });
  }

  void _onSubmit() {
    widget.onChange(_inputValue);
    setState(() {
      _submitInputValue = _inputValue;
    });
  }

  Future<Null> _openDialog() async {
    setState(() {
      _inputValue = _submitInputValue;
    });

    bool isDialogPositive = await DialogPredefined.showContentDialog(
      context,
      widget.titleDialog ?? widget.title,
      TextField(
        onChanged: _onInputChange,
        controller: TextEditingController(text: _inputValue),
        decoration: InputDecoration(hintText: widget.hintText),
      ),
      FlutterI18n.translate(context, StrKey.SUBMIT),
      FlutterI18n.translate(context, StrKey.CANCEL),
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
      onTap: _openDialog,
    );
  }
}
