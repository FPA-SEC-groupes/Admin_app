import 'package:flutter/material.dart';

class CustomAppBarWithSearch extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final bool isSearching;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggle;
  final bool automaticallyImplyLeading;
  final String? hintText;

  const CustomAppBarWithSearch({super.key,
    required this.title,
    required this.isSearching,
    required this.onSearchChanged,
    required this.onSearchToggle, required this.automaticallyImplyLeading,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? TextField(
        onChanged: onSearchChanged,
        decoration:  InputDecoration(
          hintText:hintText ?? "Rechercher...",
          border: InputBorder.none,
        ),
      )
          : Text(title),
      elevation: 1,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            onTap: onSearchToggle,
            child:  Icon(
              isSearching?Icons.close_rounded:Icons.search,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
