import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/treeview/node.dart';
import 'package:myagenda/widgets/ui/treeview/treenode.dart';

class TreeView extends StatefulWidget {
  final Map<String, dynamic> dataSource;
  final String treeTitle;

  const TreeView({Key key, this.treeTitle, this.dataSource}) : super(key: key);

  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  Node _tree;

  void didChangeDependencies() {
    super.didChangeDependencies();
    _tree = Node(key: widget.treeTitle);
    buildTree(_tree, widget.dataSource);
  }

  buildTree(Node origin, Map<String, dynamic> resources) {
    resources.keys.forEach((key) {
      Node child = Node(key: key, parent: origin);
      if (resources[key] is Map) {
        buildTree(child, resources[key]);
      } else {
        child.value = resources[key];
      }
      origin.children.add(child);
    });
  }

  _checkAllNodeChild(Node parent) {
    parent.children.forEach((child) {
      if (child.children.length == 0)
        _toggleCheckBox(child);
      else
        _checkAllNodeChild(child);
    });
  }

  _toggleCheckBox(Node child) {
    setState(() {
      child.checked = !child.checked;
    });
  }

  List<Widget> _generateChildren(Node origin, int level) {
    List<Widget> children = [];
    if (origin.children.length == 0) {
      children.add(TreeNode(
        level: level,
        node: origin,
        onChanged: (checked) => _toggleCheckBox(origin),
      ));
    } else {
      children.add(TreeNode(
        level: level,
        node: origin,
        onChanged: (checked) => _checkAllNodeChild(origin),
      ));
      origin.children.forEach((child) {
        children.addAll(_generateChildren(child, level + 1));
      });
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: _generateChildren(_tree, 0));
  }
}
