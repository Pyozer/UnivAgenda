class HelpItem {
  final String title;
  final String page;

  HelpItem(this.title, this.page);

  factory HelpItem.fromJson(Map<String, dynamic> json, [lang = "en"]) {
    String title;
    try {
      title = json['title'][lang];
    } catch (_) {
      lang = "en";
      title = json['title']['en'];
    }
    String page = json['page'];
    return HelpItem(title, "${page}_$lang.md");
  }
}
