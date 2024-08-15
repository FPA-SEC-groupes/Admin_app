import 'package:flutter/material.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view/manager/list_shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../utils/const.dart';
class UpadateDayOff extends StatefulWidget {
  final date;
  final waiter;
  final Shift? shiftToUpdate;

  const UpadateDayOff({Key? key, required this.date, required this.waiter, this.shiftToUpdate}) : super(key: key);

  @override
  State<UpadateDayOff> createState() => _UpadateDayOffState();
}

class _UpadateDayOffState extends State<UpadateDayOff> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late String _selectedDuration;
  late String _selectedDayOff;
  List<Shift> _shifts = [];
  List<Shift> _selectedShifts = [];
  late ShiftViewModel shiftViewModel;

  @override
  void initState() {
    super.initState();
    shiftViewModel = ShiftViewModel(context);
    _startTimeController = TextEditingController(text: widget.shiftToUpdate?.startTime ?? '');
    _endTimeController = TextEditingController(text: widget.shiftToUpdate?.endTime ?? '');
    print(widget.date);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedDuration = initListDurations(context).first;
    _selectedDayOff = initListDaysOff(context).first;
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
  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListShiftsByWaiterId(waiter: widget.waiter,),
            ),
          );
          return true;
        },
        child:
      Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.updateDayOff) ,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdown(
                      label: AppLocalizations.of(context)!.dayOff,
                      value: _selectedDayOff,
                      items: initListDaysOff(context),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDayOff = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 20,),
                    _buildDropdown(
                      label: AppLocalizations.of(context)!.duration,
                      value: _selectedDuration,
                      items: initListDayOffDurations(context),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDuration = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          DateTime startDate = DateTime.now(); // Adjust this as needed
                          int durationInWeeks = _selectedDuration == AppLocalizations.of(context)!.oneWeek
                              ? 1
                              : _selectedDuration == AppLocalizations.of(context)!.twoWeeks
                              ? 2
                              : _selectedDuration == AppLocalizations.of(context)!.threeWeeks
                              ? 3
                              : 4; // Default to 4 weeks if not one of the above

                          await shiftViewModel.updateDayOff(
                            widget.waiter.id,
                            _localizedDayToEnglish(context, _selectedDayOff),
                            DateFormat('yyyy-MM-dd').format(widget.date),
                            durationInWeeks,
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          Navigator.pop(context, false);
                          print("Error updating day off: $e");
                        }
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              )
            ]
        ),
      ),
    ));
  }
}
