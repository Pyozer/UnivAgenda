import 'package:flutter/material.dart';

class RadioList extends StatefulWidget {
  final List<String> values;
  final ValueChanged<String> onChange;
  final String? selectedValue;

  const RadioList({
    Key? key,
    required this.values,
    required this.onChange,
    this.selectedValue,
  }) : super(key: key);

  @override
  _RadioListState createState() => _RadioListState();
}

class _RadioListState extends State<RadioList> {
  String? _selectedChoice;

  @override
  void initState() {
    super.initState();
    if (widget.selectedValue != null &&
        widget.values.contains(widget.selectedValue)) {
      _selectedChoice = widget.selectedValue;
    } else if (widget.selectedValue == null && widget.values.isNotEmpty) {
      _selectedChoice = widget.values[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final valuesSize = widget.values.length;

    if (valuesSize == 0) return const SizedBox.shrink();

    return Column(
      children: List<RadioListTile>.generate(
        valuesSize,
        (int index) {
          return RadioListTile<String>(
            activeColor: Theme.of(context).colorScheme.secondary,
            value: widget.values[index],
            groupValue: _selectedChoice,
            title: Text(widget.values[index]),
            onChanged: (String? value) {
              setState(() => _selectedChoice = value);
              widget.onChange(widget.values[index]);
            },
          );
        },
      ),
    );
  }
}
