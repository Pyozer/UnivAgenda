import 'package:flutter/material.dart';

class TreeView extends StatefulWidget {
  final Map<String, dynamic> dataSource;
  final String treeTitle;

  const TreeView({Key key, this.treeTitle, this.dataSource}) : super(key: key);

  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  Node _tree;
  List<String> _listChecked = [];

  void didChangeDependencies() {
    super.didChangeDependencies();

    _tree = Node(widget.treeTitle);
    buildTree(_tree, widget.dataSource);
  }

  buildTree(Node origin, Map<String, dynamic> resources) {
    resources.keys.forEach((key) {
      Node child = Node(key);
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
      if (_listChecked.contains(child.key))
        _listChecked.remove(child.key);
      else
        _listChecked.add(child.key);
    });
  }

  List<Widget> _generateChildren(Node origin, int level) {
    List<Widget> children = [];
    if (origin.children.length == 0) {
      children.add(Padding(
        padding: EdgeInsets.only(left: level * 20.0),
        child: CheckboxListTile(
          onChanged: (checked) {
            _toggleCheckBox(origin);
          },
          value: _listChecked.contains(origin.key),
          title: Text(origin.key, overflow: TextOverflow.ellipsis),
        ),
      ));
    } else {
      children.add(Padding(
        padding: EdgeInsets.only(left: level * 20.0),
        child: CheckboxListTile(
          onChanged: (checked) {
            _checkAllNodeChild(origin);
          },
          value: _listChecked.contains(origin.key),
          title: Text(origin.key, overflow: TextOverflow.ellipsis),
        ),
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

class Node {
  String key;
  dynamic value;
  List<Node> children;

  Node([this.key, this.value, this.children]) {
    key ??= "";
    children ??= [];
  }

  int countLastChild() {
    if (children.length == 0) return 1;

    int totalChild = 0;
    children.forEach((child) {
      totalChild += child.countLastChild();
    });

    return totalChild;
  }

  int countNumberChildNodes() {
    int totalChild = 1;
    children.forEach((child) {
      totalChild += child.countNumberChildNodes();
    });

    return totalChild;
  }

  String toString() {
    if (children.length < 1)
      return "\"$key\": $value,\n";
    else {
      var elemsStr = '';
      this.children.forEach((elem) {
        elemsStr += elem.toString();
      });
      return "\n\"$key\": {\n" + elemsStr + "\n},";
    }
  }
}
