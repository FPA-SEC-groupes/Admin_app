import 'package:flutter/material.dart';
import 'package:hello_way/utils/routes.dart';
import 'package:hello_way/view/manager/list_shift.dart';
import 'package:intl/intl.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../../utils/const.dart';

class ShiftDialogPage extends StatefulWidget {
  final DateTime date;
  final  waiterId;
  final Shift? shiftToUpdate;

  const ShiftDialogPage({Key? key, required this.date, required this.waiterId, this.shiftToUpdate}) : super(key: key);

  @override
  _ShiftDialogPageState createState() => _ShiftDialogPageState();
}

class _ShiftDialogPageState extends State<ShiftDialogPage> {
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedDuration = initListDurations(context).first;
    _selectedDayOff = initListDaysOff(context).first;
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shiftToUpdate == null ? AppLocalizations.of(context)!.addShift : AppLocalizations.of(context)!.shift),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(widget.date),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildTimePickerField(
                context: context,
                controller: _startTimeController,
                label: AppLocalizations.of(context)!.startTime,
                validator: MultiValidator([
                  RequiredValidator(
                      errorText: AppLocalizations.of(context)!.inputRequiredError),
                ]),
              ),
              SizedBox(height: 16),
              _buildTimePickerField(
                context: context,
                controller: _endTimeController,
                label: AppLocalizations.of(context)!.endTime,
                validator: MultiValidator([
                  RequiredValidator(
                      errorText: AppLocalizations.of(context)!.inputRequiredError),
                ]),
              ),
              SizedBox(height: 16),
              _buildDropdown(
                label: AppLocalizations.of(context)!.duration,
                value: _selectedDuration,
                items: initListDurations(context),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDuration = newValue!;
                    if (_selectedDuration == AppLocalizations.of(context)!.oneDay) {
                      _selectedDayOff = AppLocalizations.of(context)!.none;
                    }
                  });
                },
              ),
              if (_selectedDuration != AppLocalizations.of(context)!.oneDay)
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
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveShift();
                  }
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
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

  void _saveShift() async {
    List<Shift> shifts = [];
    DateTime current = widget.date;
    int increment = 1;

    final localizations = AppLocalizations.of(context);

    switch (_selectedDuration) {
      case '1 day':
      case '1 jour':
      case 'يوم واحد':
        shifts.add(Shift(
          waiterId: widget.waiterId,
          dayOfWeek: DateFormat('EEEE').format(widget.date),
          date: DateFormat('yyyy-MM-dd').format(widget.date),
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
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

    if (increment > 1) {
      for (int i = 0; i < increment; i++) {
        String dayOfWeek = DateFormat('EEEE').format(current);
        if (_selectedDayOff == localizations!.none ||
            _selectedDayOff != _localizedWeekday(localizations, dayOfWeek)) {
          shifts.add(Shift(
            waiterId: widget.waiterId,
            dayOfWeek: dayOfWeek,
            date: DateFormat('yyyy-MM-dd').format(current),
            startTime: _startTimeController.text,
            endTime: _endTimeController.text,
          ));
        }
        current = current.add(Duration(days: 1));
      }
    }

    print(shifts.toString());
    try {
      await shiftViewModel.createShift(shifts);
      setState(() {
        _shifts.addAll(shifts);
        _selectedShifts = _getShiftsForDay(widget.date);
      });
      print(_shifts.toString());
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      print("Error creating shifts: $e");
      Navigator.pop(context, false); // Return false to indicate failure
    }
  }

  String _localizedWeekday(AppLocalizations localizations, String weekday) {
    switch (weekday) {
      case 'Monday':
        return localizations.monday;
      case 'Tuesday':
        return localizations.tuesday;
      case 'Wednesday':
        return localizations.wednesday;
      case 'Thursday':
        return localizations.thursday;
      case 'Friday':
        return localizations.friday;
      case 'Saturday':
        return localizations.saturday;
      case 'Sunday':
        return localizations.sunday;
      default:
        return weekday;
    }
  }

  List<Shift> _getShiftsForDay(DateTime date) {
    // Implement your logic to filter shifts for the given day
    return [];
  }
}
