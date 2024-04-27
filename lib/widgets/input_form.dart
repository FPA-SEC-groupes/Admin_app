import 'package:flutter/material.dart';

import '../res/app_colors.dart';

class InputForm extends StatelessWidget {
  final String? hint;
  final Widget? prefixIcon;
  final TextInputType? keyboard;
  final TextInputAction? action;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  final int? maxLines;
  final TextInputType? keyboardType;

  const InputForm({
    this.hint,
    this.prefixIcon,
    this.keyboard,
    this.action,
    this.onSaved,
    this.validator,
    this.contentPadding,
    this.controller,
    this.maxLines,
    this.keyboardType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      keyboardType: keyboardType,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:  const BorderSide(
            color: orange,
          ),
        ),
        prefixIcon: prefixIcon,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        isDense: true,
      ),
      validator: validator,
      controller: controller,

    );
  }
}

