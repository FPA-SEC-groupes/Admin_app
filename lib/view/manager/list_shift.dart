import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view/manager/add_shift.dart';
import 'package:hello_way/view/manager/update_dayOff.dart';
import 'package:hello_way/view/manager/update_shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../utils/const.dart';

class ListShiftsByWaiterId extends StatefulWidget {
  final  waiterId;

  ListShiftsByWaiterId({required this.waiterId});

  @override
  _ListShiftsByWaiterIdState createState() => _ListShiftsByWaiterIdState();
}

class _ListShiftsByWaiterIdState extends State<ListShiftsByWaiterId> {
  bool _isSearching = false;
  String _searchQuery = '';
  DateTime? _selectedDate;
  List<Shift> _shifts = [];
  List<Shift> _selectedShifts = [];
  late ShiftViewModel shiftViewModel;
  String? dayOff;
  late String _selectedDuration;
  late String _selectedDayOff;

  @override
  void initState() {
    super.initState();
    shiftViewModel = ShiftViewModel(context);
    _fetchShifts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedDuration = initListDurations(context).first;
    _selectedDayOff = initListDaysOff(context).first;
  }


  void _navigateToShiftDialog(BuildContext context, DateTime selectedDate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftDialogPage(
          date: selectedDate,
          waiterId: widget.waiterId,
        ),
      ),
    );

    if (result == true) {
      // Refresh the data if shifts were created successfully
      _refreshShifts();
    }
  }

  void _refreshShifts() {
    _fetchShifts();
    setState(() {
      _selectedShifts = _getShiftsForDay(_selectedDate!);
    });
  }

  void _fetchShifts() async {
    try {
      List<Shift> fetchedShifts = await shiftViewModel.getShiftsByWaiterId1(widget.waiterId);
      setState(() {
        _shifts = fetchedShifts;
      });
      Set<String> daysOfWeek = _shifts.map((shift) => shift.dayOfWeek).toSet();
      List<String> allDays = [
        'SUNDAY',
        'MONDAY',
        'TUESDAY',
        'WEDNESDAY',
        'THURSDAY',
        'FRIDAY',
        'SATURDAY'
      ];


      for (String day in allDays) {
        if (!daysOfWeek.contains(day)) {
          setState(() {
            _selectedDayOff = day;
          });
          break;
        }
      }


    } catch (e) {
      print("Error fetching shifts: $e");
    }
  }

  List<Shift> _getShiftsForDay(DateTime day) {
    return _shifts.where((shift) => shift.date == DateFormat('yyyy-MM-dd').format(day)).toList();
  }

  // void _showShiftDialog(BuildContext context, DateTime date, {Shift? shiftToUpdate}) {
  //   final _startTimeController = TextEditingController(text: shiftToUpdate?.startTime ?? '');
  //   final _endTimeController = TextEditingController(text: shiftToUpdate?.endTime ?? '');
  //   final _formKey = GlobalKey<FormState>();
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(DateFormat('EEEE, MMM d, yyyy').format(date)),
  //             Text(shiftToUpdate == null ? AppLocalizations.of(context)!.addShift : AppLocalizations.of(context)!.shift),
  //           ],
  //         ),
  //         content: Form(
  //           key: _formKey,
  //           child:SingleChildScrollView(
  //             child:Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextFormField(
  //                   controller: _startTimeController,
  //                   decoration: InputDecoration(
  //                     labelText: AppLocalizations.of(context)!.startTime,
  //                   ),
  //                   validator: MultiValidator([
  //                     RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
  //                   ]),
  //                   onTap: () async {
  //                     TimeOfDay? picked = await showTimePicker(
  //                       context: context,
  //                       initialTime: TimeOfDay.now(),
  //                       builder: (BuildContext context, Widget? child) {
  //                         return MediaQuery(
  //                           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
  //                           child: child!,
  //                         );
  //                       },
  //                     );
  //                     if (picked != null) {
  //                       _startTimeController.text = picked.format(context);
  //                     }
  //                   },
  //                 ),
  //                 TextFormField(
  //                   controller: _endTimeController,
  //                   decoration: InputDecoration(
  //                     labelText: AppLocalizations.of(context)!.endTime,
  //                   ),
  //                   validator: MultiValidator([
  //                     RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
  //                   ]),
  //                   onTap: () async {
  //                     TimeOfDay? picked = await showTimePicker(
  //                       context: context,
  //                       initialTime: TimeOfDay.now(),
  //                       builder: (BuildContext context, Widget? child) {
  //                         return MediaQuery(
  //                           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
  //                           child: child!,
  //                         );
  //                       },
  //                     );
  //                     if (picked != null) {
  //                       _endTimeController.text = picked.format(context);
  //                     }
  //                   },
  //                 ),
  //                 _buildDropdown(
  //                   label: AppLocalizations.of(context)!.duration,
  //                   value: _selectedDuration,
  //                   items: initListDurations(context),
  //                   onChanged: (String? newValue) {
  //                     setState(() {
  //                       _selectedDuration = newValue!;
  //                       if (_selectedDuration == AppLocalizations.of(context)!.oneDay) {
  //                         _selectedDayOff = AppLocalizations.of(context)!.none;
  //                       }
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //           )
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text(AppLocalizations.of(context)!.cancel),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               if (_formKey.currentState!.validate()) {
  //                 if (shiftToUpdate != null) {
  //                   try {
  //                     setState(() {
  //                       shiftToUpdate.startTime = _startTimeController.text;
  //                       shiftToUpdate.endTime = _endTimeController.text;
  //                     });
  //                     _saveShift(shiftToUpdate.startTime, shiftToUpdate.endTime, date);
  //                     // await shiftViewModel.updateShift(shiftToUpdate);
  //                   } catch (e) {
  //                     print("Error updating shift: $e");
  //                   }
  //                 } else {
  //                   _saveShift(_startTimeController.text, _endTimeController.text, date);
  //                 }
  //                 Navigator.of(context).pop();
  //               }
  //             },
  //             child: Text(AppLocalizations.of(context)!.save),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // String _localizedDayToEnglish(BuildContext context, String localizedDay) {
  //   final localizations = AppLocalizations.of(context)!;
  //
  //   final dayMap = {
  //     localizations.monday: 'Monday',
  //     localizations.tuesday: 'Tuesday',
  //     localizations.wednesday: 'Wednesday',
  //     localizations.thursday: 'Thursday',
  //     localizations.friday: 'Friday',
  //     localizations.saturday: 'Saturday',
  //     localizations.sunday: 'Sunday',
  //   };
  //
  //   return dayMap[localizedDay] ?? localizedDay;
  // }

  // void _UpadateDayOff(BuildContext context) {
  //   final _formKey = GlobalKey<FormState>();
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: []
  //         ),
  //         content: Form(
  //           key: _formKey,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               _buildDropdown(
  //                 label: AppLocalizations.of(context)!.duration,
  //                 value: _selectedDuration,
  //                 items: initListDurations(context),
  //                 onChanged: (String? newValue) {
  //                   setState(() {
  //                     _selectedDuration = newValue!;
  //                     if (_selectedDuration == AppLocalizations.of(context)!.oneDay) {
  //                       _selectedDayOff = AppLocalizations.of(context)!.none;
  //                     }
  //                   });
  //                 },
  //               ),
  //               if (_selectedDuration != AppLocalizations.of(context)!.oneDay)
  //                 _buildDropdown(
  //                   label: AppLocalizations.of(context)!.dayOff,
  //                   value: _selectedDayOff,
  //                   items: initListDaysOff(context),
  //                   onChanged: (String? newValue) {
  //                     setState(() {
  //                       _selectedDayOff = newValue!;
  //                     });
  //                   },
  //                 ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text(AppLocalizations.of(context)!.cancel),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               if (_formKey.currentState!.validate()) {
  //                 try {
  //                   DateTime startDate = DateTime.now(); // Adjust this as needed
  //                   int durationInWeeks = _selectedDuration == AppLocalizations.of(context)!.oneWeek
  //                       ? 1
  //                       : _selectedDuration == AppLocalizations.of(context)!.twoWeeks
  //                       ? 2
  //                       : _selectedDuration == AppLocalizations.of(context)!.threeWeeks
  //                       ? 3
  //                       : 4; // Default to 4 weeks if not one of the above
  //
  //                   await shiftViewModel.updateDayOff(
  //                     widget.waiterId,
  //                     _localizedDayToEnglish(context, _selectedDayOff),
  //                     DateFormat('yyyy-MM-dd').format(startDate),
  //                     durationInWeeks,
  //                   );
  //
  //                   Navigator.of(context).pop(); // Close the dialog
  //                 } catch (e) {
  //                   print("Error updating day off: $e");
  //                 }
  //               }
  //             },
  //             child: Text(AppLocalizations.of(context)!.save),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // Widget _buildDropdown({
  //   required String label,
  //   required String value,
  //   required List<String> items,
  //   required ValueChanged<String?> onChanged,
  // }) {
  //   return InputDecorator(
  //     decoration: InputDecoration(
  //       labelText: label,
  //       border: OutlineInputBorder(),
  //       contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: value,
  //         isExpanded: true,
  //         onChanged: onChanged,
  //         items: items.map<DropdownMenuItem<String>>((String value) {
  //           return DropdownMenuItem<String>(
  //             value: value,
  //             child: Text(value),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  // void _saveShift(String startTime, String endTime, DateTime date) async {
  //   List<Shift> shifts = [];
  //   DateTime current = date;
  //   int increment = 1;
  //
  //   final localizations = AppLocalizations.of(context);
  //
  //   switch (_selectedDuration) {
  //     case '1 day':
  //     case '1 jour':
  //     case 'يوم واحد':
  //       shifts.add(Shift(
  //         waiterId: widget.waiterId,
  //         dayOfWeek: DateFormat('EEEE').format(date),
  //         date: DateFormat('yyyy-MM-dd').format(date),
  //         startTime: startTime,
  //         endTime: endTime,
  //       ));
  //       break;
  //     case '1 week':
  //     case '1 semaine':
  //     case 'أسبوع واحد':
  //       increment = 7;
  //       break;
  //     case '2 weeks':
  //     case '2 semaines':
  //     case 'أسبوعين':
  //       increment = 14;
  //       break;
  //     case '3 weeks':
  //     case '3 semaines':
  //     case '3 أسابيع':
  //       increment = 21;
  //       break;
  //     case '1 month':
  //     case '1 mois':
  //     case 'شهر واحد':
  //       increment = 30;
  //       break;
  //   }
  //   print('Day offfffffffffff: $_selectedDayOff');
  //   if (increment > 1) {
  //     for (int i = 0; i < increment; i++) {
  //       String dayOfWeek = DateFormat('EEEE').format(current);
  //       if (_selectedDayOff == localizations!.none ||
  //           _selectedDayOff.toUpperCase() != dayOfWeek.toUpperCase()) {
  //         shifts.add(Shift(
  //           waiterId: widget.waiterId,
  //           dayOfWeek: dayOfWeek,
  //           date: DateFormat('yyyy-MM-dd').format(current),
  //           startTime: startTime,
  //           endTime: endTime,
  //         ));
  //       }
  //       current = current.add(Duration(days: 1));
  //     }
  //
  //   }
  //
  //   print(shifts.toString());
  //   try {
  //     await shiftViewModel.updateShifts(shifts);
  //     setState(() {
  //       _shifts.addAll(shifts);
  //       _selectedShifts = _getShiftsForDay(date);
  //     });
  //     print(_shifts.toString());
  //     Navigator.pop(context, true); // Return true to indicate success
  //   } catch (e) {
  //     print("Error creating shifts: $e");
  //     Navigator.pop(context, false); // Return false to indicate failure
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.orange,
        title: _isSearching
            ? TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search,
            border: InputBorder.none,
          ),
        )
            : Text(AppLocalizations.of(context)!.shift),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = '';
              });
            },
          ),

        ],
      ),
      floatingActionButton:
      SpeedDial(
        icon: Icons.calendar_month,
        backgroundColor: Colors.orange,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        children: [
          SpeedDialChild(
            child: Icon(Icons.calendar_month),
            label: 'Add Shift',
            backgroundColor: Colors.orange,
            onTap: () {
              if (_selectedDate != null) {
                _navigateToShiftDialog(context, _selectedDate!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.pleaseSelectDate),
                  ),
                );
              }
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.edit_calendar), // Choose a different icon for the second button
            label: 'Upadate DayOff', // Customize the label
            backgroundColor: Colors.green,  // Use a different color for distinction
            onTap: () {
              setState(() {
                _selectedDayOff = initListDaysOff(context).first;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpadateDayOff(
                    date: _selectedDate,
                    waiterId: widget.waiterId,
                  ),
                ),
              );
              // _UpadateDayOff(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 500,
            child: SfCalendar(
              view: CalendarView.month,
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
                agendaItemHeight: 0,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  setState(() {
                    _selectedDate = details.date;
                    _selectedShifts = _getShiftsForDay(_selectedDate!);
                  });
                }
              },
            ),
          ),
          Expanded(
            child: _selectedDate != null
                ? _selectedShifts.isNotEmpty
                ? ListView.builder(
              itemCount: _selectedShifts.length,
              itemBuilder: (context, index) {
                Shift shift = _selectedShifts[index];
                return ListTile(
                  title: Text('${shift.date} (${shift.dayOfWeek})'),
                  subtitle: Text('${shift.startTime} - ${shift.endTime}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpadateShift(
                            date: DateFormat('yyyy-MM-dd').parse(shift.date),
                            waiterId: widget.waiterId,
                            dayOff:_selectedDayOff
                          ),
                        ),
                      );
                      // _showShiftDialog(context, DateFormat('yyyy-MM-dd').parse(shift.date), shiftToUpdate: shift);
                    },
                  ),
                );
              },
            )
                : Center(
              child: Text(AppLocalizations.of(context)!.noShifts),
            )
                : Center(
              child: Text(AppLocalizations.of(context)!.selectDate),
            ),
          ),
        ],
      ),
    );
  }
}
