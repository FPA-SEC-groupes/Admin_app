import 'package:flutter/material.dart';
import 'package:hello_way/res/app_colors.dart';

import 'input_form.dart';
class CustomDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? message;
  final void Function()? submit;
  final void Function()? cancel;


  CustomDialog({super.key,
    required this.title,
    required this.hint,
    required this.validator,
    required this.keyboardType,
    required this.controller,
     this.message,
    required this.submit,
    required this.cancel,
  });

  @override
  State<StatefulWidget> createState() => CustomDialogState();
}

class CustomDialogState extends State<CustomDialog> {
  final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.message!=null?
          Text(widget.message!):const SizedBox(),
          const SizedBox(height: 20),
          Form(
            key: _dialogFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputForm(
                  keyboardType: widget.keyboardType,
                  controller: widget.controller,
                  hint: widget.hint,
                  validator: widget.validator,
                ),

              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: widget.cancel,
          child: const Text(
            "Annuler",
            style: TextStyle(color: orange),
          ),
        ),
        TextButton(
          onPressed: widget.submit,
          child: const Text(
            "Confirmer",
            style: TextStyle(color: orange),
          ),
        ),
      ],
    );
  }
}
