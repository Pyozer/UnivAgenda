import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../keys/url.dart';
import '../utils/functions.dart';
import '../utils/http/http_request.dart';
import '../utils/translations.dart';

class ChangeLog extends StatelessWidget {
  const ChangeLog({Key? key}) : super(key: key);

  Future<String> _fetchData(BuildContext context) async {
    final response = await HttpRequest.get(
      i18n.currentLanguage == 'fr' ? Url.changelogFr : Url.changelog,
    );
    if (response.isSuccess) return response.httpResponse!.body;
    return '## **NETWORK ERROR**';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchData(context),
      builder: (_, snapshot) => (snapshot.hasData)
          ? Markdown(
              data: snapshot.data!,
              onTapLink: (_, href, __) => openLink(null, href!, null),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
