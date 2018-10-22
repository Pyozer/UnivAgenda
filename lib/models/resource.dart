class Resource {
  final String name;
  final int resourceId;

  Resource(this.name, this.resourceId);

  String toString() {
    return "{ name: $name, resId: $resourceId }";
  }
}
