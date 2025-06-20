import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/shift.dart';
import '../../view_model/ShiftViewModel.dart';
import '../../res/app_colors.dart';

class WaiterShiftPage extends StatefulWidget {
  WaiterShiftPage({Key? key}) : super(key: key);

  @override
  _WaiterShiftPageState createState() => _WaiterShiftPageState();
}

class _WaiterShiftPageState extends State<WaiterShiftPage> {
  DateTime? _selectedDate;
  List<Shift> _shifts = [];
  late ShiftViewModel shiftViewModel;

  @override
  void initState() {
    super.initState();
    shiftViewModel = ShiftViewModel(context);
    _fetchShifts();
  }

  Future<void> _fetchShifts() async {
    try {
      List<Shift> fetchedShifts = await shiftViewModel.getShiftsByWaiterId();
      setState(() {
        _shifts = fetchedShifts;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.shift),
      ),
      body: Column(
        children: [
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              dataSource: ShiftDataSource(_getAppointments()),
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
                agendaItemHeight: 50,
              ),
              onTap: _onCalendarTap,
            ),
          ),
          // if (_selectedDate != null)
          //   Expanded(
          //     child: ListView(
          //       children: _shifts.where((shift) => shift.date == DateFormat('yyyy-MM-dd').format(_selectedDate!)).map((shift) {
          //         return ListTile(
          //           title: Text(shift.type == "shift" ? "${shift.date} ${AppLocalizations.of(context)!.shift}" : AppLocalizations.of(context)!.dayOff),
          //           subtitle: shift.type == "shift" ? Text('${shift.startTime} - ${shift.endTime}') : null,
          //         );
          //       }).toList(),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class ShiftDataSource extends CalendarDataSource {
  ShiftDataSource(List<Appointment> source) {
    appointments = source;
  }
}
