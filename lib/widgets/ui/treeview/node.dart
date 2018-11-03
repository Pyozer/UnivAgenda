class Node {
  String key;
  dynamic value;
  List<Node> children;
  Node parent;
  bool checked;
  bool isExpanded;
  bool isHidden;

  Node({
    this.key = "",
    this.value,
    this.children,
    this.parent,
    this.checked = false,
    this.isExpanded = false,
    this.isHidden = false
  }) {
    children ??= [];
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}
