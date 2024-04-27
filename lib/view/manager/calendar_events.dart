

import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/event.dart';
import 'package:hello_way/view/manager/add_party_event.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../utils/routes.dart';
import '../../view_model/events_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarEvents extends StatefulWidget {
  /// Creates the home page to display teh calendar widget.
  const CalendarEvents({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CalendarEventsState createState() => _CalendarEventsState();
}

class _CalendarEventsState extends State<CalendarEvents> {



  late final EventsViewModel _eventsViewModel ;
  final List<Meeting> _events = <Meeting>[];

  DateTime? selectedDate;


  @override
  void initState() {
    _eventsViewModel = EventsViewModel(context);
    _fetchEvents();
    super.initState();

  }

  Future<List<Event>> _fetchEvents() async {
    // fetch the list of categories using
    List<Event> events = await _eventsViewModel.getEventsBySpaceId();

    for(var event in events){

      final DateTime startTime = DateTime(event.startDate.year, event.startDate.month, event.startDate.day,event.startDate.hour,event.startDate.minute);
      final DateTime endTime = DateTime(event.endDate.year, event.endDate.month, event.endDate.day,event.endDate.hour,event.endDate.minute);

      setState(() {
        _events.add(Meeting(event.eventTitle, startTime, endTime,event.percentage==null? const Color(0xFF0F8644):orange, false,event.description));
      });

    }

    return events;
  }
  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.myEvents),
        actions: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, listEventsRoute);
                },
              ))
        ],
      ),
        floatingActionButton: DraggableFab(
            child: FloatingActionButton(
              onPressed: () {

                DateTime now=DateTime.now();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPartyEvent(startDate:selectedDate==null? DateTime(now.year,now.month,now.day,now.hour,now.minute) : selectedDate!,
                    ),
                  )
                ).then((_) {
                  setState(() {
                    _fetchEvents();
                  });
                }).catchError((error) {
                  // Handle signup error
                });
              },
              backgroundColor: orange,
              child: const Icon(Icons.add),
            )),
        body:networkStatus == NetworkStatus.Online
            ? SfCalendar(
          view: CalendarView.month,
          dataSource: MeetingDataSource(_events),
          // by default the month appointment display mode set as Indicator, we can
          // change the display mode as appointment using the appointment display
          // mode property
          monthViewSettings: const MonthViewSettings(
             // appointmentDisplayMode: MonthAppointmentDisplayMode.appointment

            showAgenda: true,


          ),

           onTap: (CalendarTapDetails details) {
        // Handle the tap event
        if (details.targetElement == CalendarElement.calendarCell) {
      // User tapped on a date cell
          DateTime now = DateTime.now();
          selectedDate=DateTime( details.date!.year, details.date!.month, details.date!.day,now.hour,now.minute);
      print('Tapped on date: $selectedDate');
    } else if (details.targetElement == CalendarElement.appointment) {
    // User tapped on an appointment
          final meeting = details.appointments!.toList()[0] as Meeting;;
    print('Tapped on appointment: '+meeting.description);
    }
    },





        ):Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.network_check,
                  size: 150,
                  color: gray,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.noInternet,
                  style: const TextStyle(fontSize: 22, color: gray),
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppLocalizations.of(context)!.checkYourInternet,
                  style: const TextStyle(fontSize: 22, color: gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10,),
                MaterialButton(
                  color: orange,
                  height: 40,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed:(){
                    setState(() {

                    });
                  },


                  child: Text(
                    AppLocalizations.of(context)!.retry,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                )
              ],
            ),
          ),
        ),);
  }

}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay,this.description);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
  String description;
}