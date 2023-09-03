class Resource {
  final String name;
  final int resourceId;

  Resource(this.name, this.resourceId);

  @override
  String toString() {
    return '{ name: $name, resId: $resourceId }';
  }
}
