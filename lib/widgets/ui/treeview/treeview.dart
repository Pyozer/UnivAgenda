import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/treeview/node.dart';
import 'package:myagenda/widgets/ui/treeview/treenode.dart';

class TreeView extends StatefulWidget {
  final Map<String, dynamic> dataSource;
  final String treeTitle;
  final ValueChanged<List<Node>> onCheckedChanged;

  const TreeView(
      {Key key,
      @required this.treeTitle,
      @required this.dataSource,
      @required this.onCheckedChanged})
      : super(key: key);

  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  Node _tree;
  List<Node> _selectedNodes = [];

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

  _checkAllNodeChild(Node node, bool checked) {
    node.checked = checked;
    node.children.forEach((child) {
      if (child.children.length == 0)
        _checkNodeCheckBox(child, checked);
      else
        _checkAllNodeChild(child, checked);
    });
  }

  _checkNodeCheckBox(Node node, bool checked) {
    setState(() {
      node.checked = checked;
    });
    if (checked)
      _selectedNodes.add(node);
    else
      _selectedNodes.remove(node);
    widget.onCheckedChanged(_selectedNodes);
  }

  _checkParentNodeCheckBox(Node node) {
    var nodeParent = node.parent;
    while (nodeParent != null) {
      bool isChildrenChecked = true;
      for (Node child in nodeParent.children) {
        if (!child.checked) {
          isChildrenChecked = false;
          break;
        }
      }
      _checkNodeCheckBox(nodeParent, isChildrenChecked);
      nodeParent = nodeParent.parent;
    }
  }

  List<Widget> _generateChildren(Node origin, int level) {
    List<Widget> children = [];
    if (origin.children.length == 0) {
      children.add(TreeNode(
        level: level,
        node: origin,
        onChanged: (checked) {
          _checkNodeCheckBox(origin, checked);
          _checkParentNodeCheckBox(origin);
        },
      ));
    } else {
      children.add(TreeNode(
        level: level,
        node: origin,
        onChanged: (checked) {
          _checkAllNodeChild(origin, checked);
          _checkParentNodeCheckBox(origin);
        },
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
