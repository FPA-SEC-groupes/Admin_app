import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hello_way/models/user.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../view_model/waiters_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WaiterDetails extends StatefulWidget {
  final User waiter;
  const WaiterDetails({super.key, required this.waiter});

  @override
  State<WaiterDetails> createState() => _WaiterDetailsState();
}

class _WaiterDetailsState extends State<WaiterDetails> {
  late final WaitersViewModel _waitersViewModel ;
  DateTime currentDate = DateTime.now();
  @override
  void initState() {
    _waitersViewModel = WaitersViewModel(context);
    getServerSumCommandsPerDay(widget.waiter.id);
    getServerSumCommandsPerMonth(widget.waiter.id);
    getServerCommandsCountPerDay(widget.waiter.id);
    super.initState();
  }

  Future<double> getServerSumCommandsPerDay(serverId) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    double sum = await _waitersViewModel.getServerSumCommandsPerDay(
        serverId, formattedDate);
    return sum;
  }
  Future<int>  getServerCommandsCountPerDay(serverId) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    int sum = await _waitersViewModel.getServerCommandsCountPerDay(
        serverId, formattedDate);
    return sum;
  }

  Future<double> getServerSumCommandsPerMonth(serverId) async {
    String formattedDate = DateFormat('yyyy-MM').format(currentDate);
    double sum = await _waitersViewModel.getServerSumCommandsPerMonth(
        serverId, formattedDate);
    return sum;
  }

  launchCaller(String phoneNumber) async {
    final PermissionStatus status = await Permission.phone.request();
    if (status == PermissionStatus.granted) {
      // Remplacez par votre numéro de téléphone
      final uri = Uri.parse(phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Impossible de lancer l\'appel : $phoneNumber';
      }
    } else {
      throw 'La permission d\'accéder au téléphone n\'a pas été accordée';
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar: Toolbar(
        title: "${widget.waiter.name!} ${widget.waiter.lastname!}",
      ),
      body:networkStatus == NetworkStatus.Online
          ? Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: gray.withOpacity(0.5),
                      backgroundImage: widget.waiter.image == null
                          ? null
                          : MemoryImage(base64.decode(widget.waiter.image!)),
                      child: widget.waiter.image == null
                          ? const Icon(
                        Icons.person_rounded,
                        size: 100,
                        color: Colors.white,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          launchCaller("tel:${widget.waiter.phone!}");
                        },
                        child: Container(
                          height: 35,
                          constraints: const BoxConstraints(
                            minWidth: 25,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                              const Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                              Text(
                                AppLocalizations.of(context)!.call,
                                style: const TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),


                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "${widget.waiter.name!} ${widget.waiter.lastname!}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 5),
                      child: Text(
                        widget.waiter.email,
                      ),
                    ),
                  ],
                ))
              ],
            ),
            const SizedBox(height: 50,),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: orange, // Or any color you want
                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text("${AppLocalizations.of(context)!.on} ${DateFormat('dd-MM-yyyy').format(currentDate)}",style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<double>(
                          future: getServerSumCommandsPerDay(widget.waiter.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              double sum = snapshot.data!;
                              return Column(

                                children: [
                                  SvgPicture.asset('assets/images/coin.svg',
                                      height: 60, width: 60, color: Colors.white),
                                  Text('$sum ${AppLocalizations.of(context)!.tunisianDinar}',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child:FutureBuilder<int>(
                        future: getServerCommandsCountPerDay(widget.waiter.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            int nbOrders = snapshot.data!;
                            return Column(
                              children: [
                                const Icon(
                                  Icons.file_copy,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                Text('$nbOrders ${AppLocalizations.of(context)!.orders}',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                              ],
                            );
                          }
                        },
                      ),)
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: orange, // Or any color you want
                  borderRadius: BorderRadius.circular(10.0),
                  // Adjust the radius as needed
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${AppLocalizations.of(context)!.on} ${DateFormat('MM-yyyy').format(currentDate)}",style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                    FutureBuilder<double>(
              future: getServerSumCommandsPerMonth(widget.waiter.id),
              builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      double sum = snapshot.data!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/images/coin.svg',
                              height: 60, width: 60, color: Colors.white),
                          Text('$sum ${AppLocalizations.of(context)!.tunisianDinar}',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                        ],
                      );
                    }
              },
            ),
                  ],
                ))
          ],
        ),
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
