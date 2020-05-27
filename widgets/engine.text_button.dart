import 'package:clientf/flutter_engine/widgets/engine.space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// EngineButton 과 비슷한데, 그냥 텍스트로 클릭이 되는 것이다.
class EngineTextButton extends StatelessWidget {
  EngineTextButton({
    this.loader = false,
    this.padding = const EdgeInsets.all(8.0),
    this.text,
    this.onTap,
  });
  final bool loader;
  final String text;
  final Function onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            if (loader) ...[
              PlatformCircularProgressIndicator(),
              EngineHalfSpace(),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}
