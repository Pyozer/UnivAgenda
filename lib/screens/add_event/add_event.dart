import 'package:color_picker/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  bool _isCustomColor = false;
  Color _customColor;

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: "Add event",
      actions: <Widget>[
        IconButton(icon: const Icon(Icons.check), onPressed: () {})
      ],
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.title),
                title: TextFormField(
                  decoration: InputDecoration.collapsed(hintText: "Title"),
                ),
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: TextFormField(
                  decoration: InputDecoration.collapsed(hintText: "Location"),
                ),
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: TextFormField(
                  decoration: InputDecoration.collapsed(hintText: "Date"),
                ),
              ),
              Divider(height: 4.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Heure début", border: InputBorder.none),
                      ),
                    ),
                  ),
                  Container(width: 16.0),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Heure fin", border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: Text("Custom color"),
                trailing: Switch(
                    value: _isCustomColor,
                    activeColor: Theme.of(context).accentColor,
                    onChanged: (value) {
                      setState(() {
                        _isCustomColor = value;
                      });
                    }),
              ),
              _isCustomColor
                  ? ListTileColor(
                      title: "Event color",
                      description: "Custom color of this event",
                      defaultColor: _customColor ?? Colors.red,
                      onColorChange: (color) {
                        setState(() {
                          _customColor = color;
                        });
                      },
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
