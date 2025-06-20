import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/utils/routes.dart';
import 'package:hello_way/view/manager/add_shift.dart';
import 'package:hello_way/view/manager/update_dayOff.dart';
import 'package:hello_way/view/manager/update_shift.dart';
import 'package:hello_way/view/manager/waiter_details.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:form_field_validator/form_field_validator.dart';
import '../../main.dart';
import '../../utils/const.dart';

class ListShiftsByWaiterId extends StatefulWidget {
  final  waiter;

  ListShiftsByWaiterId({required this.waiter});

  @override
  _ListShiftsByWaiterIdState createState() => _ListShiftsByWaiterIdState();
}

class _ListShiftsByWaiterIdState extends State<ListShiftsByWaiterId>  {
  bool _isSearching = false;
  String _searchQuery = '';
  DateTime? _selectedDate;
  List<Shift> _shifts = [];
  List<Shift> _selectedShifts = [];
  late ShiftViewModel shiftViewModel;
  String? dayOff;
  late String _selectedDuration;
  late String _selectedDayOff;
  List<String> allDays = [
    'SUNDAY',
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY'
  ];

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




  bool isSelectedDateInShifts(DateTime? _selectedDate, List<Shift> _selectedShifts) {
    if (_selectedDate == null) {
      return false; // Return false if _selectedDate is null
    }

    // Convert _selectedDate to a string in the same format as the Shift date
    String selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    for (Shift shift in _selectedShifts) {
      if (shift.date == selectedDateString) {
        return true; // Return true if the date matches
      }
    }
    return false; // Return false if no match is found
  }
  bool isDateTodayOrFuture(DateTime? selectedDate) {
    if (selectedDate == null) {
      return false;
    }
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    return selected.isAtSameMomentAs(today) || selected.isAfter(today);
  }
  void _navigateToShiftDialog(BuildContext context, DateTime selectedDate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftDialogPage(
          date: selectedDate,
          waiter: widget.waiter,
        ),
      ),
    );

    if (result == true) {
      // Refresh the data if shifts were created successfully
      _refreshShifts();
    }
  }
  void _updateShift(BuildContext context, Shift shift) async {
    final result =Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>UpadateShift(
              shiftToUpdate: shift,
              date: DateFormat('yyyy-MM-dd').parse(shift.date),
              waiter: widget.waiter,
              dayOff:findNewDayOff(_selectedDate!),
            )
        )
    ).then((_) {
      _refreshShifts();
      // setState(() {
      //   _fetchShifts();
      // });
    }).catchError((error) {
      // Handle signup error
    });

    if (result == true) {
      // Refresh the data if shifts were created successfully
      _refreshShifts();
    }
  }
  void _updateDayOff(BuildContext context,DateTime selectedDate) async {
    if (selectedDate != null && isSelectedDateInShifts(selectedDate , _shifts)) {
        final result =Navigator.push(
              context,MaterialPageRoute(
              builder: (context) =>UpadateDayOff(
                date: selectedDate,
                waiter: widget.waiter,
              )
          )
          ).then((_) {
          _refreshShifts();
          // setState(() {
          //   _fetchShifts();
          // });
        }).catchError((error) {
          // Handle signup error
        });
        if (result == true) {
          // Refresh the data if shifts were created successfully
          _refreshShifts();
        }
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectShift),
        ),
      );
    }

  }
  void _refreshShifts() {

    setState(() {
      _fetchShifts();
      _selectedShifts = _getShiftsForDay(_selectedDate!);
    });
  }
  String? findNewDayOff( DateTime startDate) {
    List<Shift> filteredShifts = _shifts.where((shift) {
      DateTime shiftDate = DateTime.parse(shift.date);
      return !shiftDate.isBefore(startDate);
    }).toList();

    String? currentDayOff;
    for (Shift shift in filteredShifts) {
      if (shift.type == 'dayOff') {
        DateTime date = DateTime.parse(shift.date);
       return currentDayOff = DateFormat('EEEE').format(date).toUpperCase();
        break;
      }
    }

    // Find a new day off if there is no current day off
    // if (currentDayOff == null) {
    //   int startIndex = allDays.indexOf(startDay);
    //   for (int i = 0; i < allDays.length; i++) {
    //     int index = (startIndex + i) % allDays.length;
    //     String day = allDays[index];
    //     if (!daysWithShifts.contains(day)) {
    //       return day;
    //     }
    //   }
    // } else {
    //   return currentDayOff;
    // }

    return null; // In case no suitable day is found
  }
  void _fetchShifts() async {
    try {
      _shifts.clear();
      List<Shift> fetchedShifts = await shiftViewModel.getShiftsByWaiterId1(widget.waiter.id);
      setState(() {
        _shifts = fetchedShifts;
      });

      // Get the days of the week when the waiter has shifts or days off
      Set<String> daysWithShifts = _shifts.map((shift) {
        DateTime date = DateTime.parse(shift.date);
        String dayOfWeek = DateFormat('EEEE').format(date).toUpperCase();
        return dayOfWeek;
      }).toSet();
      String? currentDayOff;
      for (Shift shift in _shifts) {
        if (shift.type == 'dayOff') {
          DateTime date = DateTime.parse(shift.date);
          currentDayOff = DateFormat('EEEE').format(date).toUpperCase();
          break;
        }

      }

      // Find a new day off if there is no current day off
      if (currentDayOff == null) {
        for (String day in allDays) {
          if (!daysWithShifts.contains(day)) {
            setState(() {
              _selectedDayOff = day;
            });
            break;
          }
        }
      } else {
        setState(() {
          _selectedDayOff = currentDayOff!;
        });
      }
    } catch (e) {
      print("Error fetching shifts: $e");
    }
  }
  List<Appointment> _getAppointments() {
    return _shifts.map((shift) {
      DateTime shiftDate = DateTime.parse(shift.date);
      return Appointment(
        startTime: shiftDate,
        endTime: shiftDate,
        subject: shift.type == 'shift' ? AppLocalizations.of(context)!.shift : AppLocalizations.of(context)!.dayOff,
        color: shift.type == 'shift' ? Colors.green : Colors.red,
      );
    }).toList();
  }
  void _onCalendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      setState(() {
        _selectedDate = details.date;
      });
    }
  }
  List<Shift> _getShiftsForDay(DateTime day) {
    return _shifts.where((shift) => shift.date == DateFormat('yyyy-MM-dd').format(day)).toList();
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

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WaiterDetails(
              waiter: widget.waiter,
            ),
          ),
        );
      return true;
    },
    child:
      Scaffold(
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
            label: AppLocalizations.of(context)!.addShift,
            backgroundColor: Colors.orange,
            onTap: () {
              if (_selectedDate == null  ) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.pleaseSelectDate),
                  ),
                );
              } else if(isSelectedDateInShifts(_selectedDate , _shifts)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.pleaseSelectDate),
                  ),
                );
              }else if(isDateTodayOrFuture(_selectedDate)){
                 _navigateToShiftDialog(context, _selectedDate!);
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.isDateTodayOrFuture),
                  ),
                );
              }
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.edit_calendar), // Choose a different icon for the second button
            label: AppLocalizations.of(context)!.updateDayOff, // Customize the label
            backgroundColor: Colors.green,  // Use a different color for distinction
            onTap: () {
                          setState(() {
                            _selectedDayOff = initListDaysOff(context).first;
                          });
                          _updateDayOff(context,_selectedDate!);
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
              dataSource: ShiftDataSource(_getAppointments()),
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
                  title: shift.type=="shift" ?Text('${shift.date} ${AppLocalizations.of(context)!.shift}'):Text(AppLocalizations.of(context)!.dayOff),
                  subtitle:shift.type=="shift" ? Text('${shift.startTime} - ${shift.endTime}'):Text(''),
                  trailing:shift.type=="shift" ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _updateShift(context, shift);

                      // _showShiftDialog(context, DateFormat('yyyy-MM-dd').parse(shift.date), shiftToUpdate: shift);
                    },
                  ):Text(''),
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
      )
    );
  }
}
class ShiftDataSource extends CalendarDataSource {
  ShiftDataSource(List<Appointment> source) {
    appointments = source;
  }
}

