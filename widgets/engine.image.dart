import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class EngineImage extends StatelessWidget {
  EngineImage(this.url);
  final String url;
  @override
  Widget build(BuildContext context) {


    if (url.indexOf('http') != 0) return Icon(Icons.error);


    // print('egine image url: $url');

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => PlatformCircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
