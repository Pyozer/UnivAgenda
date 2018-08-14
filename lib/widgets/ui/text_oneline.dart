import 'package:flutter/material.dart';

class TextOneLine extends Text {
  const TextOneLine(data,
      {Key key, style, textAlign, textDirection, softWrap, textScaleFactor})
      : super(data,
            style: style,
            textAlign: textAlign,
            textDirection: textDirection,
            softWrap: softWrap,
            textScaleFactor: textScaleFactor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            key: key);
}
