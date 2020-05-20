
import '../engine.globals.dart';
import 'package:flutter/material.dart';

/// Text widget that supports i18n tranlsation.
Text T(
  data, {
  Key key,
  style,
  strutStyle,
  textAlign,
  textDirection,
  locale,
  softWrap,
  overflow,
  textScaleFactor,
  maxLines,
  semanticsLabel,
  textWidthBasis,
}) {
  return Text(
    t(data),
    key: key,
    style: style,
    strutStyle: strutStyle,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    textWidthBasis: textWidthBasis,
  );
}
