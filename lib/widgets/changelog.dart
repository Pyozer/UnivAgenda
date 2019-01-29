import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/http/http_request.dart';

class ChangeLog extends StatelessWidget {
  Future<String> _fetchData(BuildContext context) async {
    Locale locale = Localizations.localeOf(context);

    String changeLogUrl = Url.changelog;
    if (locale.countryCode == "fr") changeLogUrl = Url.changelogFr;

    final response = await HttpRequest.get(changeLogUrl);
    if (response.isSuccess) return response.httpResponse.body;
    return "## **NETWORK ERROR**";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchData(context),
      builder: (_, snapshot) => (snapshot.hasData)
          ? Markdown(
              data: snapshot.data,
              onTapLink: (href) => openLink(null, href, null))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
