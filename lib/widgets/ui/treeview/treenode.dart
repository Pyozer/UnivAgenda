import 'package:flutter/material.dart';
import 'package:univagenda/widgets/ui/custom_checkbox.dart';
import 'package:univagenda/widgets/ui/treeview/node.dart';

class TreeNode extends StatelessWidget {
  final int level;
  final Node node;
  final String? title;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onExpandChanged;

  const TreeNode({
    Key? key,
    required this.level,
    required this.node,
    this.title,
    required this.onChanged,
    this.onExpandChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = (node.children.isNotEmpty)
        ? TextStyle(fontWeight: FontWeight.w700)
        : TextStyle(fontWeight: FontWeight.w400);

    final expandBtn = (node.children.isEmpty)
        ? const SizedBox(width: 30.0)
        : IconButton(
            icon: Icon(
              node.isExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
            ),
            onPressed: onExpandChanged,
          );

    return ListTile(
      onTap: () {
        if (node.checked == null) {
          onChanged(false);
        } else {
          onChanged(!(node.checked!));
        }
      },
      title: Padding(
        padding: EdgeInsets.only(left: level * 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            expandBtn,
            Expanded(
              child: Text(
                title ?? node.key,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
      trailing: CustomCheckbox(
        value: node.checked,
        onChanged: onChanged,
        activeColor: Theme.of(context).accentColor,
      ),
    );
  }
}
