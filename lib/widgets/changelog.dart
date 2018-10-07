import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/http/http_request.dart';

class ChangeLog extends StatelessWidget {
  Future<String> _fetchData() async {
    final response = await HttpRequest.get(Url.changelog);
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
                  onTapLink: (String href) => openLink(null, href, null))
              : Center(
                  child: CircularProgressIndicator(),
                ),
    );
  }
}
