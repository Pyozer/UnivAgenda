class HelpItem {
  final String title;
  final String filename;

  const HelpItem(this.title, this.filename);

  factory HelpItem.fromJson(Map<String, dynamic> json) {
    return HelpItem(json['title'], json['filename']);
  }
}
