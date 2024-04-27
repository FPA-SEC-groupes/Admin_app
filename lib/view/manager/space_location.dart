import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/space.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SpaceLocation extends StatefulWidget {
  SpaceLocation({Key? key}) : super(key: key);

  @override
  State<SpaceLocation> createState() => SpaceLocationState();
}

class SpaceLocationState extends State<SpaceLocation> {
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final space = ModalRoute.of(context)!.settings.arguments as Space;
    return Scaffold(
        appBar: Toolbar(
          title: AppLocalizations.of(context)!.location,
        ),
        body:networkStatus == NetworkStatus.Online
            ? GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(
               space.latitude,space.longitude),
            zoom: 16.0,
          ),
          // enable user location

          padding: const EdgeInsets.only(bottom: 70.0),
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: {
            Marker(
              markerId: MarkerId(space.title),
              position: LatLng(
                 space.latitude, space.longitude),
              infoWindow: InfoWindow(
                title: space.title,
              ),
            ),
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
        ),);
  }
}
