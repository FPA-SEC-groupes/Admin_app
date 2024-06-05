import 'package:flutter/material.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WaiterShiftPage extends StatefulWidget {
  WaiterShiftPage({Key? key}) : super(key: key);

  @override
  _WaiterShiftPageState createState() => _WaiterShiftPageState();
}

class _WaiterShiftPageState extends State<WaiterShiftPage> {
  bool _isSearching = false;
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

  void _fetchShifts() async {
    try {
      List<Shift> fetchedShifts = await shiftViewModel.getShiftsByWaiterId();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.orange,
        title: Text('Shifts'),
      ),
      body: Column(
        children: [
          Container(
            height: 500, // Increase this height to make the calendar bigger
            child: SfCalendar(
              view: CalendarView.month,
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
                agendaItemHeight: 0, // Set the agenda item height to 0 to remove "No events"
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
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.noShifts),
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
