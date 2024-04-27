import 'package:flutter/material.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/view/manager/reservation_details.dart';
import 'package:provider/provider.dart';
import '../../models/reservation.dart';
import '../../services/network_service.dart';
import '../../shimmer/item_reservation_shimmer.dart';
import '../../view_model/reservations_view_model.dart';
import '../../widgets/item_reservation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ListReservations extends StatefulWidget {
  const ListReservations({super.key});

  @override
  State<ListReservations> createState() => _ListReservationsState();
}

class _ListReservationsState extends State<ListReservations> {
  late ReservationsViewModel _listReservationsViewModel ;

  Future<List<Reservation>> getReservationsBySpaceId() async {
    List<Reservation> reservations = await _listReservationsViewModel.getReservationsBySpaceId();
    return reservations;
  }


  @override
  void initState() {
    // TODO: implement initState
    _listReservationsViewModel = ReservationsViewModel(context);
    getReservationsBySpaceId( );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.myReservations),
      ),
      body:networkStatus == NetworkStatus.Online
          ? FutureBuilder(
        future: getReservationsBySpaceId(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Reservation>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              itemCount: 10,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return const ItemReservationShimmer();
              },
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
                      AppLocalizations.of(context)!.noBooking,
                      style: const TextStyle(fontSize: 22, color: gray),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else {
            final reservations = snapshot.data!;
            return ListView.separated(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                  Reservation reservation = reservations[index];

                      return GestureDetector(
                        child: ItemReservation(reservation: reservation,


                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationDetails(reservation: reservation,

                              ),
                            ),
                          );
                        },
                      );

              },
              separatorBuilder: (context, index) {
                return Container(
                  color: lightGray,
                  height: 10,
                );
              },
            );
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
      ),
    );
  }
}
