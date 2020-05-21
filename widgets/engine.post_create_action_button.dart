import 'package:flutter/material.dart';

class PostCreateActionButton extends StatelessWidget {
  PostCreateActionButton(this.id, this.onTap);

  final String id;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(Icons.add),
      onTap: onTap,
    );
  }
}
