import 'package:flutter/material.dart';
import 'package:hello_way/widgets/input_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class MyDialogue extends StatefulWidget {
  final String title;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final void Function()? submit;

  final void Function()? cancel;
  const MyDialogue({super.key, required this.title, this.validator, this.controller, this.submit, this.cancel, this.keyboardType, });

  @override
  _MyDialogueState createState() => _MyDialogueState();
}

class _MyDialogueState extends State<MyDialogue> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title:  Text(widget.title), //
      content: InputForm(
          keyboardType: widget.keyboardType ,
        controller:widget.controller  , // _titleCategoryController,
        hint:  AppLocalizations.of(context)!.title,
        validator: widget.validator
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed:widget.cancel
        ),
        MaterialButton(
          child:  Text(AppLocalizations.of(context)!.confirm),
          onPressed: widget.submit
        ),
      ],
    );
  }
}