import 'package:flutter/material.dart';

import '../res/app_colors.dart';
class Toolbar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final List<Widget>? actions;

  const Toolbar({super.key,  required this.title, this.actions});


  @override
  Widget build(BuildContext context) {
    return AppBar(

      backgroundColor: orange,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      actions:actions,
      elevation: 0,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
