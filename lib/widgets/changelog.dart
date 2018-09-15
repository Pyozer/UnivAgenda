import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/http/http_request.dart';

const changelogUrl = 'https://raw.githubusercontent.com/Pyozer/MyAgenda_Flutter/master/CHANGELOG.md';

class ChangeLog extends StatelessWidget {

  Future<String> _fetchData() async {
    final response = await HttpRequest.get(changelogUrl);
    if (response.isSuccess)
      return response.httpResponse.body;
    else
      return "## **NETWORK ERROR**";
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
              : Center(
                  child: CircularProgressIndicator(),
                ),
    );
  }
}
