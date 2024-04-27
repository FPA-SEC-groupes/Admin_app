import 'dart:async';

import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/event.dart';
import 'package:hello_way/utils/routes.dart';
import 'package:hello_way/widgets/party_item.dart';
import 'package:hello_way/widgets/promotion_item.dart';
import 'package:provider/provider.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../utils/const.dart';
import '../../view_model/events_view_model.dart';
import 'add_new_promotion.dart';
import 'add_party_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListEvents extends StatefulWidget {
  @override
  _ListEventsState createState() => _ListEventsState();
}

class _ListEventsState extends State<ListEvents> {
  late final EventsViewModel _eventsViewModel ;
  bool _isSearching = false;
  String _searchQuery = '';
  @override
  void initState() {
    _eventsViewModel = EventsViewModel(context);
    super.initState();
    // fetch the initial list of zones and update the state
    _fetchEvents();
  }

  Future<List<Event>> _fetchEvents() async {
    // fetch the list of categories using
    List<Event> events = await _eventsViewModel.getEventsBySpaceId();
    return events;
  }

  Future<void> actionPopUpItemSelected1(String value,Event event) async {
    if (value == delete) {

    } else if (value == edit) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  AddPartyEvent(
              party: event,
            ),
          )
      ).then((_) {
        setState(() {
          _fetchEvents();
        });
      }).catchError((error) {
        // Handle signup error
      });
    }
  }

  Future<void> actionPopUpItemSelected(String value,Event event) async {
    if (value == delete) {
      // Your delete logic
    }
    else if (value == edit) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNewPromotion(promotionId: event.idEvent),
        ),
      ).then((value) {
       setState(() {
         _fetchEvents();
       });
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
        backgroundColor: lightGray,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: orange,
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
              : Text(AppLocalizations.of(context)!.myEvents),
          actions: [

            IconButton(
              icon:  Icon( _isSearching?Icons.close_rounded:Icons.search,),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  _searchQuery ='';
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              onPressed: () {
                Navigator.pushReplacementNamed(context, calendarEventsRoute);
              },
            ),
          ],
        ),
        floatingActionButton: DraggableFab(
            child: FloatingActionButton(
              onPressed: () {

                DateTime now=DateTime.now();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPartyEvent(
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
            ? FutureBuilder(
            future: _fetchEvents(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return  Center(
                  child: Text( AppLocalizations.of(context)!.errorRetrievingData),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_sharp,
                          size: 150,
                          color: gray,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.noEvents,
                          style: const TextStyle(fontSize: 22, color: gray),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else {

                final List<Event> events;
                if (_searchQuery.isEmpty) {
                  events = snapshot.data!;
                } else {
                  events = (snapshot.data! as List<Event>)
                      .where((event) =>event.eventTitle
                      .toLowerCase().contains(_searchQuery.toLowerCase()) )

                      .toList();
                }
                return ListView.separated(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    Event event = events[index];

                    return event.percentage != null
                        ? ItemPromotion(event: event,onActionPopUpItemSelected: actionPopUpItemSelected,)
                        : ItemParty(event: event,onActionPopUpItemSelected: actionPopUpItemSelected1,);
                  },
                  separatorBuilder: (context, index) {
                    return Container(
                      color: lightGray,
                      height: 10,
                    );
                  },
                );
              }
            }):Center(
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
                SizedBox(height: 10,),
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
