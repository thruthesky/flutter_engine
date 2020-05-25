import 'dart:io';
import 'package:clientf/flutter_engine/widgets/engine.image.dart';

import '../engine.defines.dart';
import '../engine.model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// `EngineAppBar` Widget
///
/// [title] is an empty string by default.
///
/// [elevation] is the z-index of the appbar.
///   if not specified and if the current platform is `IOS` it will automatically be set to `0.0`, and `1.0` for `Android`.
///
/// [centerTitle] is `true` by default. if [actions] is specified it will be automatically set to `false`.
///
/// [actions] can accept any widget, it is preferabble to use button widgets.
///   if this is specified and the current scaffold which this `EngineAppBar` widget belongs to have an `endDrawer`
///   it will show an internal `Menu` Button to open the drawer.
///
/// [backgroundColor] is for the app bar color.
///
/// [automaticallyImplyLeading] is `true` by default, if set to `false`, it will not display the back button when navigating.
///
///
class EngineAppBar extends StatelessWidget with PreferredSizeWidget {
  EngineAppBar({
    this.title = '',
    this.elevation,
    this.centerTitle = true,
    this.actions,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.onPressedCreatePostButton,
    this.displayUserPhoto = true,
    @required this.onTapUserPhoto,
  });

  final String title;
  final bool centerTitle;
  final double elevation;
  final Widget actions;
  final Color backgroundColor;
  final bool automaticallyImplyLeading;
  final Function onPressedCreatePostButton;
  final bool displayUserPhoto;

  final Function onTapUserPhoto;

  _openAppDrawer(ScaffoldState scaffold) {
    if (scaffold.hasDrawer) {
      scaffold.openDrawer();
    } else if (scaffold.hasEndDrawer) {
      scaffold.openEndDrawer();
    } else {
      /// do nothing ...
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);

    return AppBar(
      title: Text(title),
      centerTitle: actions == null ? centerTitle : false,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation == null ? Platform.isIOS ? 0.0 : 1.0 : elevation,
      backgroundColor: backgroundColor,
      actions: <Widget>[
        if (actions != null) actions,
        if (displayUserPhoto) UserPhoto(onTapUserPhoto),
        AppTitleMenuIcon(
          visible: scaffold.hasEndDrawer,
          onTap: () => _openAppDrawer(scaffold),
        ),
      ],
    );
  }
}

class UserPhoto extends StatelessWidget {
  const UserPhoto(
    this.onTap, {
    Key key,
  }) : super(key: key);

  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(),
      child: Material(
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.blueAccent,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Selector<EngineModel, String>(
            builder: (context, url, child) {
              if (url == null || url == '' || url == DELETED_PHOTO) {
                return Image.asset(
                    'lib/flutter_engine/assets/images/user-icon.png');
              } else {
                return EngineImage(url);

                // return Image(
                //   image: NetworkImageWithRetry(url),
                //   fit: BoxFit.cover,
                // );
              }
            },
            selector: (_, model) => model.user?.photoUrl,
          ),
        ),
      ),
    );
  }
}

class AppTitleMenuIcon extends StatelessWidget {
  AppTitleMenuIcon({this.visible, this.onTap});

  final bool visible;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.0,
      child: Visibility(
        visible: visible,
        child: FlatButton(
          child: Icon(
            Icons.menu,
            size: 30,
            color: Colors.white,
            // key: Key(AppService.key.drawerOpen),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
