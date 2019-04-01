import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/treeview/node.dart';
import 'package:myagenda/widgets/ui/treeview/treenode.dart';

class TreeView extends StatefulWidget {
  final Map<String, dynamic> dataSource;
  final String treeTitle;
  final ValueChanged<HashSet<Node>> onCheckedChanged;
  final String search;

  const TreeView({
    Key key,
    @required this.treeTitle,
    @required this.dataSource,
    @required this.onCheckedChanged,
    this.search,
  }) : super(key: key);

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  Node _tree;
  HashSet<Node> _selectedNodes = HashSet();

  void didChangeDependencies() {
    super.didChangeDependencies();
    _tree = Node(key: widget.treeTitle, isExpanded: true);
    buildTree(_tree, widget.dataSource);
  }

  void didUpdateWidget(covariant TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final search = widget.search?.trim()?.toLowerCase();
    _setAllNodeVisible(_tree);
    if (search != null && search.isNotEmpty) _filterTree(_tree, search);
  }

  void buildTree(Node origin, Map<String, dynamic> resources) {
    resources.keys.forEach((key) {
      Node child = Node(key: key, parent: origin);
      if (resources[key] is Map)
        buildTree(child, resources[key]);
      else
        child.value = resources[key];
      origin.children.add(child);
    });
  }

  _checkAllNodeChild(Node node, bool checked) {
    node.checked = checked;
    node.children.forEach((child) {
      if (child.children.isEmpty)
        _checkNodeCheckBox(child, checked);
      else
        _checkAllNodeChild(child, checked);
    });
  }

  _checkNodeCheckBox(Node node, bool checked) {
    if (node.checked == checked) return;

    setState(() => node.checked = checked);

    if (checked == true)
      _selectedNodes.add(node);
    else
      _selectedNodes.remove(node);

    widget.onCheckedChanged(_selectedNodes);
  }

  _checkParentNodeCheckBox(Node node) {
    var nodeParent = node.parent;
    while (nodeParent != null) {
      int nbCheck = 0;
      for (Node child in nodeParent.children) {
        if (child.checked == true) nbCheck += 1;
      }
      final nbrChild = nodeParent.children.length;
      var check = nbCheck == nbrChild ? true : nbCheck > 0 ? null : false;
      _checkNodeCheckBox(nodeParent, check);
      nodeParent = nodeParent.parent;
    }
  }

  _onNodeExpandChange(Node node) {
    setState(() => node.isExpanded = !node.isExpanded);
  }

  List<Widget> _generateChildren(Node origin, int level) {
    List<Widget> children = [];

    if (origin.isHidden) return children;

    if (origin.children.isEmpty) {
      children.add(TreeNode(
        level: level,
        node: origin,
        onChanged: (checked) {
          _checkNodeCheckBox(origin, checked);
          _checkParentNodeCheckBox(origin);
        },
        onExpandChanged: () => _onNodeExpandChange(origin),
      ));
    } else {
      children.add(TreeNode(
        level: level,
        node: origin,
        onChanged: (checked) {
          _checkAllNodeChild(origin, checked);
          _checkParentNodeCheckBox(origin);
        },
        onExpandChanged: () => _onNodeExpandChange(origin),
      ));
      if (origin.isExpanded) {
        origin.children.forEach((child) {
          children.addAll(_generateChildren(child, level + 1));
        });
      }
    }
    return children;
  }

  bool _filterTree(Node node, String search) {
    node.isHidden = false;
    node.isExpanded = true;

    final nodeKey = node.key.toLowerCase();
    if (nodeKey.contains(search)) return true;

    int hiddenChild = 0;
    for (Node child in node.children) {
      child.isHidden = !_filterTree(child, search);
      hiddenChild += child.isHidden ? 1 : 0;
    }

    if (node.children.length > hiddenChild) return true;

    node.isHidden = true;
    return false;
  }

  _setAllNodeVisible(Node node) {
    node.isHidden = false;
    for (Node child in node.children) {
      child.isExpanded = false;
      _setAllNodeVisible(child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: _generateChildren(_tree, 0));
  }
}
