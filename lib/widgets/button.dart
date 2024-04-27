import 'package:flutter/material.dart';
import 'package:hello_way/res/app_colors.dart';
class Button extends StatefulWidget {
  final String text;
  final void Function()? onPressed;

  const Button({
    required this.text,
    this.onPressed,
    super.key,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
   return  MaterialButton(
      color: orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      minWidth: double.infinity,
      height: 50,
      onPressed: widget.onPressed,
      child: Text(
        widget.text,
        style: const TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );

  }
}
