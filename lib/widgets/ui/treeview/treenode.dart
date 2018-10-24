import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/treeview/node.dart';

class TreeNode extends StatelessWidget {
  final int level;
  final Node node;
  final ValueChanged<bool> onChanged;

  const TreeNode({Key key, this.level, this.node, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      onChanged: onChanged,
      value: node.checked,
      title: Padding(
        padding: EdgeInsets.only(left: level * 20.0),
        child: Text(node.key, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
