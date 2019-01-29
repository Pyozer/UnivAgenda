import 'package:flutter/material.dart';

class Dropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;
  final bool isExpanded;

  const Dropdown({
    Key key,
    this.items,
    this.value,
    this.onChanged,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: isExpanded,
            value: value,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
