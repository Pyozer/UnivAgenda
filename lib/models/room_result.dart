import 'package:myagenda/models/room.dart';

class RoomResult {
  final Room room;
  final DateTime startAvailable;
  final DateTime endAvailable;

  RoomResult(this.room, this.startAvailable, this.endAvailable);

}