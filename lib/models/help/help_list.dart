import './help_item.dart';

class HelpList {
  final List<HelpItem> en;
  final List<HelpItem> fr;

  const HelpList(this.en, this.fr);

  factory HelpList.fromJson(Map<String, dynamic> json) {
    return HelpList(
      List<HelpItem>.from(json['en'].map((item) => HelpItem.fromJson(item))),
      List<HelpItem>.from(json['fr'].map((item) => HelpItem.fromJson(item))),
    );
  }

  List<HelpItem> getHelpListByLang(String lang) {
    switch (lang) {
      case 'en':
        return en;
      case 'fr':
        return fr;
      default:
        return en;
    }
  }
}
