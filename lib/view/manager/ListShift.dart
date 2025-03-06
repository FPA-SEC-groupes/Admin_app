import 'package:flutter/material.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class WaiterShiftPage extends StatefulWidget {
  const WaiterShiftPage({Key? key}) : super(key: key);

  @override
  _WaiterShiftPageState createState() => _WaiterShiftPageState();
}

class _WaiterShiftPageState extends State<WaiterShiftPage> {
  late ShiftViewModel shiftViewModel;
  late Future<List<Shift>> futureShifts;
  late Map<DateTime, List<Shift>> shiftEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    shiftViewModel = ShiftViewModel(context);
    futureShifts = shiftViewModel.getShiftsByWaiterId();
    shiftEvents = {};
  }

  /// Groups shifts by date
  void groupShiftsByDate(List<Shift> shifts) {
    shiftEvents.clear();
    for (var shift in shifts) {
      DateTime shiftDate = DateTime.parse(shift.date); // Ensure date format is 'YYYY-MM-DD'
      if (shiftEvents[shiftDate] == null) {
        shiftEvents[shiftDate] = [];
      }
      shiftEvents[shiftDate]!.add(shift);
    }
    setState(() {});
  }

  /// Returns shifts on a selected day
  List<Shift> _getShiftsForDay(DateTime day) {
    return shiftEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shifts'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Shift>>(
        future: futureShifts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error.toString()}"));
          } else if (snapshot.hasData) {
            groupShiftsByDate(snapshot.data!);
            return buildCalendar();
          } else {
            return Center(child: Text("No shifts found."));
          }
        },
      ),
    );
  }

  Widget buildCalendar() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getShiftsForDay,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
        ),
        Expanded(
          child: _selectedDay != null ? buildShiftList(_getShiftsForDay(_selectedDay!)) : Center(child: Text("Select a date to view shifts")),
        ),
      ],
    );
  }

  Widget buildShiftList(List<Shift> shifts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: shifts.length,
      itemBuilder: (context, index) {
        var shift = shifts[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.type,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('Start: ${shift.startTime.substring(0, 5)}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('End: ${shift.endTime.substring(0, 5)}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
