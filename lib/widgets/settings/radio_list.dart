import 'package:flutter/material.dart';

class RadioList extends StatefulWidget {
  final List<String> values;
  final ValueChanged<String> onChange;
  final String selectedValue;

  const RadioList({Key key, this.values, this.onChange, this.selectedValue})
      : super(key: key);

  @override
  _RadioListState createState() => _RadioListState();
}

class _RadioListState extends State<RadioList> {
  String _selectedChoice;

  @override
  void initState() {
    super.initState();
    if (widget.selectedValue != null &&
        widget.values.contains(widget.selectedValue))
      _selectedChoice = widget.selectedValue;
    else if (widget.selectedValue == null && widget.values.length > 0)
      _selectedChoice = widget.values[0];
  }

  Widget _getContent() {
    final int valuesSize = widget.values.length;

    if (valuesSize == 0) return Container();

    return Column(
        children: List<RadioListTile>.generate(valuesSize, (int index) {
      return RadioListTile<String>(
          activeColor: Theme.of(context).accentColor,
          value: widget.values[index],
          groupValue: _selectedChoice,
          title: Text(widget.values[index]),
          onChanged: (String value) {
            setState(() {
              _selectedChoice = value;
            });
            widget.onChange(widget.values[index]);
          });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return _getContent();
  }
}
