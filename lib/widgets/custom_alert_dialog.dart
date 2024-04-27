import 'package:flutter/material.dart';
import 'package:hello_way/res/app_colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String textSubmitButton;
  final String textCancelButton;
  final void Function()? submit;
  final void Function()? cancel;

  const CustomAlertDialog({
    required this.title,
    required this.message,
    required this.submit,
    required this.cancel,
    required this.textSubmitButton,
    required this.textCancelButton,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: cancel,
          child: Text(
            textCancelButton,
            style: const TextStyle(color: orange),
          ),
        ),
        TextButton(
          onPressed: submit,
          child: Text(
            textSubmitButton,
            style: const TextStyle(color: orange),
          ),
        ),
      ],
    );
  }
}
