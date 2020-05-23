
import './engine.space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class EngineButton extends StatelessWidget {
  EngineButton({
    this.loader,
    this.text,
    this.onPressed,
  });
  final bool loader;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          if (loader) ...[
            PlatformCircularProgressIndicator(),
            EngineSpace(),
          ],
          Text(text),
        ],
      ),
    );
  }
}
