import 'package:flutter/material.dart';

SnackBar customSnackBar(BuildContext context, String content, Color color) {
  return SnackBar(
      content: Text(content),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      backgroundColor: color,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height -
            kToolbarHeight -
            44 -
            MediaQuery.of(context).padding.top,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      dismissDirection: DismissDirection.none);
}
