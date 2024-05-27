import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:hello_way/utils/routes.dart';
import 'package:intl/intl.dart';
import 'package:hello_way/models/user.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:hello_way/view_model/waiters_view_model.dart';
import 'package:hello_way/utils/secure_storage.dart';

class ShiftPage extends StatefulWidget {
  const ShiftPage({Key? key}) : super(key: key);

  @override
  _ShiftPageState createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  late WaitersViewModel _waitersViewModel;
  late ShiftViewModel _shiftViewModel;
  final SecureStorage secureStorage = SecureStorage();
  late List<DateTime> startTimes;
  late List<DateTime> endTimes;
  List<User> _waiters = [];
  List<String> daysOfWeek = []; // To store days of the week
  User? selectedWaiter;

  @override
  void initState() {
    super.initState();
    _waitersViewModel = WaitersViewModel(context);
    _shiftViewModel = ShiftViewModel(context);
    _setupWeekDates(); // Setup the week dates
    _fetchWaitersBySpaceId();
  }

  void _setupWeekDates() {
    DateTime now = DateTime.now();
    int currentDayOfWeek = now.weekday;

    // Calculate the start of the week (Monday)
    DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));

    // Generate days of the week from Monday to Sunday
    daysOfWeek = List.generate(7, (index) {
      DateTime weekDay = startOfWeek.add(Duration(days: index));
      return DateFormat('EEEE, MMMM d').format(weekDay); // "Monday, May 27"
    });

    // Initialize start times and end times for each day of the week
    startTimes = List.generate(7, (index) => now);
    endTimes = List.generate(7, (index) => now);
  }

  Future<void> _fetchWaitersBySpaceId() async {
    try {
      List<User> waiters = await _waitersViewModel.getWaitersBySpaceId();
      setState(() {
        _waiters = waiters;
      });
    } catch (e) {
      print('Failed to fetch waiters: $e');
    }
  }

  Future<void> saveShift() async {
    if (selectedWaiter == null) {
      print('No waiter selected');
      return;
    }
    int waiterId = selectedWaiter!.id!;
    List<Map<String, String>> shiftTimes = [];
    for (int i = 0; i < daysOfWeek.length; i++) {
      String dayOnly = daysOfWeek[i].split(',')[0];
      shiftTimes.add({
        'dayOfWeek': dayOnly.toUpperCase(),// Ensures the day name is uppercase
        'date': DateFormat('yyyy-MM-dd').format(startTimes[i]), // Formats date as "yyyy-MM-dd"
        'startTime': DateFormat('HH:mm').format(startTimes[i]), // Formats startTime as "HH:mm"
        'endTime': DateFormat('HH:mm').format(endTimes[i]), // Formats endTime as "HH:mm"
      });
    }
      print(shiftTimes);
    try {
      await _shiftViewModel.saveShift(waiterId, shiftTimes);
      Navigator.pushNamed(context,listWaitersRoute);
      print('Shift saved successfully');
    } catch (e) {
      print('Failed to save shift: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Management'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<User>(
              value: selectedWaiter,
              hint: const Text('Select Waiter'),
              onChanged: (User? newValue) {
                setState(() {
                  selectedWaiter = newValue;
                });
              },
              items: _waiters.map<DropdownMenuItem<User>>((User user) {
                return DropdownMenuItem<User>(
                  value: user,
                  child: Text(user.username),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ...List<Widget>.generate(7, (i) => _buildTimePickerRow(i)),
            Center(
              child: ElevatedButton(
                onPressed: saveShift,
                child: const Text('Save Shift'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time for ${daysOfWeek[i]}:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Start:'),
                  TimePickerSpinner(
                    is24HourMode: true,
                    normalTextStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                    highlightedTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
                    spacing: 20,
                    itemHeight: 30,
                    isForce2Digits: true,
                    minutesInterval: 15,
                    onTimeChange: (time) {
                      setState(() {
                        startTimes[i] = DateTime(
                          startTimes[i].year,
                          startTimes[i].month,
                          startTimes[i].day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('End:'),
                  TimePickerSpinner(
                    is24HourMode: true,
                    normalTextStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                    highlightedTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
                    spacing: 20,
                    itemHeight: 30,
                    isForce2Digits: true,
                    minutesInterval: 15,
                    onTimeChange: (time) {
                      setState(() {
                        endTimes[i] = DateTime(
                          endTimes[i].year,
                          endTimes[i].month,
                          endTimes[i].day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
