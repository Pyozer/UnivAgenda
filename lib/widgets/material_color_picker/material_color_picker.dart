import 'package:flutter/material.dart';

const List<MaterialColor> materialColors = const <MaterialColor>[
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey
];

class MaterialColorPicker extends StatefulWidget {
  final MaterialType type;
  final double elevation;
  final Color selectedColor;
  final ValueChanged<Color> onColorChange;

  const MaterialColorPicker(
      {Key key,
      this.type,
      this.elevation,
      this.selectedColor,
      this.onColorChange})
      : super(key: key);

  @override
  _MaterialColorPickerState createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<MaterialColorPicker> {
  static const double _kCircleColorSize = 40.0;
  static const double _kShadeColorHeight = _kCircleColorSize;
  static const double _kColorElevation = 4.0;
  static const double _kPadding = 4.0;
  static const double _kVerticalMargin = 5.0;
  static const double _kHorizontalMargin = 8.0;
  static const double _kBorderWidth = 1.5;
  static const double _kBorderWidthSelected = 3.0;

  /// Height of widget is 4.3x size of a shade color box
  static const double _kWidgetHeight =
      (_kShadeColorHeight + _kPadding * 2 + _kVerticalMargin * 2) * 4.5;

  MaterialColor _mainColor;
  Color _shadeColor;

  @override
  void initState() {
    super.initState();
    _mainColor = materialColors[0];
    _shadeColor = _mainColor.shade500;
  }

  _onMainColorSelected(MaterialColor color) {
    setState(() {
      _mainColor = color;
      _shadeColor = _mainColor.shade500;
    });
  }

  _onShadeColorSelected(Color color) {
    setState(() {
      _shadeColor = color;
    });
  }

  Widget _buildColorCircle(MaterialColor color) {
    final isMainColor = (_mainColor == color);

    return Container(
        margin: const EdgeInsets.symmetric(
            vertical: _kVerticalMargin, horizontal: _kHorizontalMargin),
        padding: const EdgeInsets.all(_kPadding),
        child: Material(
            elevation: _kColorElevation,
            shape: CircleBorder(
                side: BorderSide(
                    color: Colors.white,
                    width:
                        isMainColor ? _kBorderWidthSelected : _kBorderWidth)),
            color: color,
            child: InkWell(
                onTap: () => _onMainColorSelected(color),
                child: Container(
                    width: _kCircleColorSize,
                    height: _kCircleColorSize,
                    color: Colors.transparent))));
  }

  List<Widget> _buildListMainColor(List<MaterialColor> colors) {
    List<Widget> circles = [];
    for (final color in colors) circles.add(_buildColorCircle(color));
    return circles;
  }

  Widget _buildShadeColor(Color color) {
    final isShadeColor = (_shadeColor == color);

    return Container(
        margin: const EdgeInsets.symmetric(
            vertical: _kVerticalMargin, horizontal: _kHorizontalMargin),
        padding: !isShadeColor ? const EdgeInsets.all(_kPadding) : null,
        child: Material(
            elevation: _kColorElevation,
            shape: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white,
                    width:
                        isShadeColor ? _kBorderWidthSelected : _kBorderWidth)),
            color: color,
            child: InkWell(
                onTap: () => _onShadeColorSelected(color),
                child: Container(
                    height: _kShadeColorHeight, color: Colors.transparent))));
  }

  List<Widget> _buildListShadesColor(MaterialColor color) {
    List<Color> shades = [
      color.shade50,
      color.shade100,
      color.shade200,
      color.shade300,
      color.shade400,
      color.shade500,
      color.shade600,
      color.shade700,
      color.shade800,
      color.shade900
    ];
    List<Widget> circles = [];
    for (final color in shades) circles.add(_buildShadeColor(color));
    return circles;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: _kWidgetHeight,
        margin: const EdgeInsets.all(12.0),
        child: Material(
            type: widget.type ?? MaterialType.card,
            elevation: widget.elevation ?? 4.0,
            child: Row(children: <Widget>[
              SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(children: _buildListMainColor(materialColors))),
              Container(width: 8.0),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildListShadesColor(_mainColor),
                  ),
                ),
              )
            ])));
  }
}
