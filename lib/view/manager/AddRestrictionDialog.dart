import 'package:flutter/material.dart';
import 'package:hello_way/models/user.dart';
import 'package:hello_way/view_model/RestrictionsViewModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/Restriction.dart';
import '../../models/reservation.dart';
class AddRestrictionDialog extends StatefulWidget {
  final RestrictionsViewModel viewModel;
  final  User user;
  final Reservation reservion;

  const AddRestrictionDialog({Key? key, required this.viewModel, required this.user, required this.reservion}) : super(key: key);

  @override
  _AddRestrictionDialogState createState() => _AddRestrictionDialogState();
}

class _AddRestrictionDialogState extends State<AddRestrictionDialog> {
  final _formKey = GlobalKey<FormState>();
  String _restrictionType = '';
  String _restrictionDescription = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addRestriction),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.restrictionDescription,
              ),
              onChanged: (value) {
                setState(() {
                  _restrictionDescription = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.submit),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Restriction restriction = Restriction(
                description: _restrictionDescription,
                user: widget.user, // Assuming User class has an 'id' field
                reservation: widget.reservion,
              );
              widget.viewModel.createRestriction(restriction).then((_) {
                Navigator.of(context).pop();
              }).catchError((error) {
                Navigator.of(context).pop();
              });
            }
          },
        ),
      ],
    );
  }
}