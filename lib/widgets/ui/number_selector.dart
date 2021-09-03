import 'package:flutter/material.dart';

const kItemheight = 40.0;
const kVisibleHeight = 150.0;

class NumberSelector extends StatefulWidget {
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final int initialValue;

  const NumberSelector({
    Key? key,
    this.min = 0,
    required this.max,
    required this.onChanged,
    this.initialValue = 0,
  })  : assert(max > min),
        assert(initialValue >= min && initialValue <= max),
        super(key: key);

  _NumberSelectorState createState() => _NumberSelectorState();
}

class _NumberSelectorState extends State<NumberSelector> {
  late ScrollController _controller;
  int _selectedValue = 0;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = ScrollController(
      initialScrollOffset: _calcOffset(_selectedValue),
    );
  }

  @override
  void didUpdateWidget(NumberSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _goToElement(_selectedValue);
  }

  double _calcOffset(int index) {
    int offsetIndex = 0 - widget.min;
    double offset = (kItemheight * (index + offsetIndex)) -
        kVisibleHeight / 2 +
        kItemheight / 2;
    return offset > 0 ? offset : 0.0;
  }

  void _goToElement(int index) {
    _controller.animateTo(
      _calcOffset(index),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onItemSelected(int index) {
    setState(() => _selectedValue = index);
    _goToElement(index);
    widget.onChanged(index);
  }

  Widget _buildItem(int value) {
    TextStyle textStyle;

    if (_selectedValue == value)
      textStyle = TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).accentColor,
      );
    else
      textStyle = TextStyle(fontSize: 20.0);

    return InkWell(
      onTap: () => _onItemSelected(value),
      child: Container(
        height: kItemheight,
        child: Center(
          child: Text(
            value.toString(),
            style: textStyle,
          ),
        ),
      ),
    );
  }

  List<Widget> _generateListItem() {
    List<Widget> items = [];
    for (int i = widget.min; i <= widget.max; i++) items.add(_buildItem(i));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kVisibleHeight,
      width: 0.0,
      child: ListView(
        controller: _controller,
        children: ListTile.divideTiles(
          context: context,
          tiles: _generateListItem(),
        ).toList(),
      ),
    );
  }
}
