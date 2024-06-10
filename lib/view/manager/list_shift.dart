import 'package:flutter/material.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view/manager/add_shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    shiftViewModel = ShiftViewModel(context);
    _fetchShifts();
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
    } catch (e) {
      print("Error fetching shifts: $e");
    }
  }

  List<Shift> _getShiftsForDay(DateTime day) {
    return _shifts.where((shift) => shift.date == DateFormat('yyyy-MM-dd').format(day)).toList();
  }

  void _showShiftDialog(BuildContext context, DateTime date, {Shift? shiftToUpdate}) {
    final _startTimeController = TextEditingController(text: shiftToUpdate?.startTime ?? '');
    final _endTimeController = TextEditingController(text: shiftToUpdate?.endTime ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('EEEE, MMM d, yyyy').format(date)),
              Text(shiftToUpdate == null ? AppLocalizations.of(context)!.addShift : AppLocalizations.of(context)!.shift),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.startTime,
                ),
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
              TextField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.endTime,
                ),
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
            ],
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
                if (shiftToUpdate != null) {
                  try {
                    setState(() {
                      shiftToUpdate.startTime = _startTimeController.text;
                      shiftToUpdate.endTime = _endTimeController.text;
                    });
                    await shiftViewModel.updateShift(shiftToUpdate);
                  } catch (e) {
                    print("Error updating shift: $e");
                  }
                } else {
                  final shift = Shift(
                    waiterId: widget.waiterId,
                    dayOfWeek: DateFormat('EEEE').format(date),
                    date: DateFormat('yyyy-MM-dd').format(date),
                    startTime: _startTimeController.text,
                    endTime: _endTimeController.text,
                  );
                  try {
                    final createdShift = await shiftViewModel.createShift(shift as List<Shift>);
                    setState(() {
                      _shifts.add(createdShift as Shift);
                      _selectedShifts = _getShiftsForDay(date);
                    });
                  } catch (e) {
                    print("Error creating shift: $e");
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
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
                      // _showShiftDialog(context, DateFormat('yyyy-MM-dd').parse(shift.date), shiftToUpdate: shift);
                    },
                  ),
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.noShifts),
                  ElevatedButton(
                    onPressed: () {
                      // _showShiftDialog(context, _selectedDate!);
                    },
                    child: Text(AppLocalizations.of(context)!.addShift),
                  ),
                ],
              ),
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
