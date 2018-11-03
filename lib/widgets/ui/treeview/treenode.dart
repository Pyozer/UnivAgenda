import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/treeview/node.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class TreeNode extends StatelessWidget {
  final int level;
  final Node node;
  final ValueChanged<bool> onChanged;
  final Function onExpandChanged;

  const TreeNode(
      {Key key, this.level, this.node, this.onChanged, this.onExpandChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = (node.children.length > 0)
        ? TextStyle(fontWeight: FontWeight.w700)
        : TextStyle(fontWeight: FontWeight.w400);

    final expandBtn = (node.children.length == 0)
        ? const SizedBox(width: 30.0)
        : IconButton(
            icon: Icon(
              node.isExpanded
                  ? OMIcons.keyboardArrowDown
                  : OMIcons.keyboardArrowRight,
            ),
            onPressed: onExpandChanged,
          );

    return ListTile(
      onTap: () => onChanged(!node.checked),
      title: Padding(
        padding: EdgeInsets.only(left: level * 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            expandBtn,
            Expanded(
              child: Text(
                node.key,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
      trailing: Checkbox(
        value: node.checked,
        onChanged: onChanged,
        activeColor: Theme.of(context).accentColor,
      ),
    );
  }
}
