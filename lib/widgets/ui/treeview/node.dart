class Node {
  String key;
  dynamic value;
  List<Node> children;
  Node parent;
  bool checked = false;

  Node({this.key, this.value, this.children, this.parent}) {
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
