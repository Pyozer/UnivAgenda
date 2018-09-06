import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/widgets/ui/circular_loader.dart';

class ChangeLog extends StatelessWidget {
  Future<String> _fetchData() async {
    final response = await http.get(
        'https://raw.githubusercontent.com/Pyozer/MyAgenda_Flutter/master/CHANGELOG.md');
    if (response.statusCode == 200)
      return response.body;
    else
      return "## **ERROR**";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchData(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
            (snapshot.hasData)
                ? Markdown(
                    data: snapshot.data,
                    onTapLink: (String href) => openLink(href))
                : Center(child: CircularLoader()));
  }
}
