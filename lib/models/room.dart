class Room {
  final String name;
  final int resourceId;

  Room(this.name, this.resourceId);

  String toString() {
    return "{ name: $name, resId: $resourceId }";
  }
}