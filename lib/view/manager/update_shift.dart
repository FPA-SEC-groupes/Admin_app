import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view/manager/list_shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../utils/const.dart';
class UpadateShift extends StatefulWidget {
  final date;
  final  waiterId;
  final dayOff;
  final Shift? shiftToUpdate;

  const UpadateShift({Key? key, required this.date, required this.waiterId,this.dayOff, this.shiftToUpdate}) : super(key: key);

  @override
  State<UpadateShift> createState() => _UpadateShiftState();
}

class _UpadateShiftState extends State<UpadateShift> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _startTimeController=TextEditingController(text: widget.shiftToUpdate?.startTime ?? '');
  late TextEditingController _endTimeController=TextEditingController(text: widget.shiftToUpdate?.endTime ?? '');
  late String _selectedDuration;
  List<Shift> _shifts = [];
  List<Shift> _selectedShifts = [];
  late ShiftViewModel shiftViewModel;

  @override
  void initState() {
    super.initState();
    shiftViewModel = ShiftViewModel(context);
    _startTimeController = TextEditingController(text: widget.shiftToUpdate?.startTime ?? '');
    _endTimeController = TextEditingController(text: widget.shiftToUpdate?.endTime ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedDuration = initListDurations(context).first;
  }
  Widget _buildTimePickerField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (picked != null) {
          controller.text = picked.format(context);
        }
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
  String _localizedDayToEnglish(BuildContext context, String localizedDay) {
    final localizations = AppLocalizations.of(context)!;

    final dayMap = {
      localizations.monday: 'Monday',
      localizations.tuesday: 'Tuesday',
      localizations.wednesday: 'Wednesday',
      localizations.thursday: 'Thursday',
      localizations.friday: 'Friday',
      localizations.saturday: 'Saturday',
      localizations.sunday: 'Sunday',
    };

    return dayMap[localizedDay] ?? localizedDay;
  }
  void _saveShift(String startTime, String endTime, DateTime date) async {
    List<Shift> shifts = [];
    DateTime current = date;
    int increment = 1;

    final localizations = AppLocalizations.of(context);

    switch (_selectedDuration) {
      case '1 day':
      case '1 jour':
      case 'يوم واحد':
        shifts.add(Shift(
          waiterId: widget.waiterId,
          dayOfWeek: DateFormat('EEEE').format(date),
          date: DateFormat('yyyy-MM-dd').format(date),
          startTime: startTime,
          endTime: endTime,
        ));
        break;
      case '1 week':
      case '1 semaine':
      case 'أسبوع واحد':
        increment = 7;
        break;
      case '2 weeks':
      case '2 semaines':
      case 'أسبوعين':
        increment = 14;
        break;
      case '3 weeks':
      case '3 semaines':
      case '3 أسابيع':
        increment = 21;
        break;
      case '1 month':
      case '1 mois':
      case 'شهر واحد':
        increment = 30;
        break;
    }
    print('Day offfffffffffff: $widget.dayOff');
    if (increment > 1) {
      for (int i = 0; i < increment; i++) {
        String dayOfWeek = DateFormat('EEEE').format(current);
        if (widget.dayOff == localizations!.none ||
            widget.dayOff.toUpperCase() != dayOfWeek.toUpperCase()) {
          shifts.add(Shift(
            waiterId: widget.waiterId,
            dayOfWeek: dayOfWeek,
            date: DateFormat('yyyy-MM-dd').format(current),
            startTime: startTime,
            endTime: endTime,
          ));
        }
        current = current.add(Duration(days: 1));
      }

    }

    print(shifts.toString());
    try {
      await shiftViewModel.updateShifts(shifts);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListShiftsByWaiterId(waiterId: widget.waiterId),
        ),
      );// Return true to indicate success
    } catch (e) {
      print("Error creating shifts: $e");
      Navigator.pop(context, false); // Return false to indicate failure
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('EEEE, MMM d, yyyy').format(widget.date)),
            Text(widget.shiftToUpdate == null ? AppLocalizations.of(context)!.addShift : AppLocalizations.of(context)!.shift),
          ],
        ),
        content: Form(
            key: _formKey,
            child:SingleChildScrollView(
              child:Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _startTimeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.startTime,
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                    ]),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        _startTimeController.text = picked.format(context);
                      }
                    },
                  ),
                  TextFormField(
                    controller: _endTimeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.endTime,
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                    ]),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        _endTimeController.text = picked.format(context);
                      }
                    },
                  ),
                  SizedBox(height: 20,),
                  _buildDropdown(
                    label: AppLocalizations.of(context)!.duration,
                    value: _selectedDuration,
                    items: initListDurations(context),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDuration = newValue!;

                      });
                    },
                  ),
                ],
              ),
            )
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (widget.shiftToUpdate != null) {
                  try {
                    setState(() {
                      widget.shiftToUpdate!.startTime = _startTimeController.text;
                      widget.shiftToUpdate!.endTime = _endTimeController.text;
                    });
                    _saveShift(widget.shiftToUpdate!.startTime, widget.shiftToUpdate!.endTime, widget.date);
                    // await shiftViewModel.updateShift(shiftToUpdate);
                  } catch (e) {
                    print("Error updating shift: $e");
                  }
                } else {
                  _saveShift(_startTimeController.text, _endTimeController.text, widget.date);
                }
                Navigator.of(context).pop();
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      );
  }
}
