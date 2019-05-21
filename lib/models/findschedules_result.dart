import 'package:myagenda/models/resource.dart';

class FindSchedulesResult {
  final Resource resource;
  final DateTime startAvailable;
  final DateTime endAvailable;

  FindSchedulesResult(this.resource, this.startAvailable, this.endAvailable);
}
