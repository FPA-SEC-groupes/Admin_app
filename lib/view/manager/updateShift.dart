import 'package:flutter/material.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:intl/intl.dart';

class UpdateShiftPage extends StatefulWidget {
  final  waiterId; // Ensuring that waiterId is of type int

  const UpdateShiftPage({Key? key, required this.waiterId}) : super(key: key);

  @override
  _UpdateShiftPageState createState() => _UpdateShiftPageState();
}

class _UpdateShiftPageState extends State<UpdateShiftPage> {
  late final ShiftViewModel _shiftViewModel;
  late Future<List<Shift>> _futureShifts;

  @override
  void initState() {
    super.initState();
    _shiftViewModel = ShiftViewModel(context);
    _futureShifts = _shiftViewModel.getShiftsByWaiterId1(widget.waiterId); // Adjusted method name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Shifts"),
        backgroundColor: Colors.orange, // Adjusted the color for better contrast
      ),
      body: FutureBuilder<List<Shift>>(
        future: _futureShifts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red, fontSize: 16)));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final shift = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    tileColor: Colors.white,
                    title: Text(
                      "${shift.dayOfWeek} - ${shift.date}",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Start: ${shift.startTime} - End: ${shift.endTime}",
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                    onTap: () => _showUpdateDialog(shift),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("No shifts found.", style: TextStyle(fontSize: 16)));
          }
        },
      ),
    );
  }


  void _showUpdateDialog(Shift shift) {
    TextEditingController startTimeController = TextEditingController(text: shift.startTime);
    TextEditingController endTimeController = TextEditingController(text: shift.endTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Shift"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(labelText: "Start Time"),
              ),
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(labelText: "End Time"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  shift.startTime = startTimeController.text;
                  shift.endTime = endTimeController.text;
                });
                _shiftViewModel.updateShift(shift);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
