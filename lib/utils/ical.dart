class Ical {

  static List<IcalModel> parseToIcal(String icalData) {
    List<String> lines = icalData.split("\n");

    List<IcalModel> events = new List();
    IcalModel event;

    lines.forEach((line) {
      if (line.startsWith('BEGIN:VEVENT')) {
        event = new IcalModel();
      } else if (line.startsWith('DTSTART')) {
        event.dtstart = _getValue(line);
      } else if (line.startsWith('DTEND')) {
        event.dtend = _getValue(line);
      } else if (line.startsWith('SUMMARY')) {
        event.summary = _getValue(line);
      } else if (line.startsWith('LOCATION')) {
        event.location = _getValue(line);
      } else if (line.startsWith('DESCRIPTION')) {
        String description = _getValue(line);
        event.description = description
            .replaceAll(new RegExp('/\\n/g'), ' ')
            .replaceAll(new RegExp('/\s\s+/g'), ' ')
            .split('(Exported')[0]
            .trim();
      } else if (line.startsWith('UID')) {
        event.uid = _getValue(line);
      } else if (line.startsWith('END:VEVENT')) {
        events.add(event);
      }
    });

    return events;
  }

  static _getValue(String line) {
    var index = line.indexOf(":"); // Gets the first index where a space occours
    return line.substring(index + 1); // Gets the value part
  }
}

class IcalModel {

  String dtstart;
  String dtend;
  String summary;
  String location;
  String description;
  String uid;

  IcalModel(
      {this.dtstart,
      this.dtend,
      this.summary,
      this.location,
      this.description,
      this.uid});

  @override
  String toString() {
    return '{dtstart: $dtstart, dtend: $dtend, summary: $summary, location: $location, description: $description, uid: $uid}';
  }

}