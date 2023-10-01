class HelpItem {
  final String title;
  final Uri fileUrl;

  const HelpItem(this.title, this.fileUrl);

  factory HelpItem.fromJson(Map<String, dynamic> json) {
    return HelpItem(json['title'], Uri.parse(json['file_url']));
  }
}
