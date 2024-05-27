import 'package:flutter/material.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';

class WaiterShiftPage extends StatefulWidget {
  const WaiterShiftPage({Key? key}) : super(key: key);

  @override
  _WaiterShiftPageState createState() => _WaiterShiftPageState();
}

class _WaiterShiftPageState extends State<WaiterShiftPage> {
  late ShiftViewModel shiftViewModel;
  late Future<List<Shift>> futureShifts;

  @override
  void initState() {
    super.initState();
    shiftViewModel = ShiftViewModel(context);
    futureShifts = shiftViewModel.getShiftsByWaiterId();
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
            return buildShiftList(snapshot.data!);
          } else {
            return Center(child: Text("No shifts found."));
          }
        },
      ),
    );
  }

  Widget buildShiftList(List<Shift> shifts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var shift in shifts) ...[
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.dayOfWeek,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Start: ${shift.startTime.substring(0, 5)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'End: ${shift.endTime.substring(0, 5)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
