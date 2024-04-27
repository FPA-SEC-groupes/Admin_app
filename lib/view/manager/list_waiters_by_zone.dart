import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/user.dart';
import 'package:hello_way/widgets/item_waiter.dart';
import 'package:provider/provider.dart';

import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../shimmer/item_waiter_shimmer.dart';
import '../../utils/const.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/waiters_view_model.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../../widgets/dropdown_button.dart';


import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ListWaitersByZone extends StatefulWidget {
  final int zoneId;
  const ListWaitersByZone({super.key, required this.zoneId});

  @override
  State<ListWaitersByZone> createState() => _ListWaitersByZoneState();
}

class _ListWaitersByZoneState extends State<ListWaitersByZone> {
  late WaitersViewModel _waitersViewModel;
  final SecureStorage secureStorage = SecureStorage();
  String? _selectedWaiter;
  List<User> listWaiters =[];


  @override
  void initState() {
    super.initState();
    _waitersViewModel = WaitersViewModel(context);
    _fetchWaitersByZoneId( widget.zoneId);

    _fetchWaitersBySpaceId();
    // fetch the initial list of zones and update the state

  }


  Future<  List<User>> _fetchWaitersByZoneId(int zoneId) async {
    // fetch the list of categories using
    List<User> boards = await _waitersViewModel.getWaitersByZoneId(zoneId);
    return boards;
  }

  Future<  List<User>> _fetchWaitersBySpaceId() async {

    List<User> waiters = await _waitersViewModel.getWaitersBySpaceId();
    setState(() {
      listWaiters=waiters;
    });

    return waiters;
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.waitersList),
      ),
      body: networkStatus == NetworkStatus.Online
          ?Column(
        children: [
            Container(
              padding: const EdgeInsets.all( 10),
              child:



              DropDownButton(
                selectedItem: _selectedWaiter,


                hint:
                  "Assign",
                items:listWaiters.where((user) => user.zone?.id != widget.zoneId).map((User waiter) {
                  final int id = waiter.id!;
                  final String name = "${waiter.name!} ${waiter.lastname!}";
                  final String zoneTitle=" (${waiter.zone?.title})";
                  return DropdownMenuItem<String>(
                    value: id.toString(),
                    child: Row(
                      children: [
                        Text(name),
                        if(waiter.zone?.title !=null)
                        Text(zoneTitle,style: TextStyle(color: gray),)
                      ],
                    ),
                  );
                }).toList(),
                validator: MultiValidator([
                  RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                ]),
                onChanged: (selectedItem) async {
                  final spaceId=await secureStorage.readData(spaceIdKey);
                  final moderatorId=await secureStorage.readData(authentifiedUserId);

                  print(spaceId.toString()+moderatorId.toString());
                  setState(() {

                    _selectedWaiter = selectedItem!;

                  });

                 await  _waitersViewModel.setServerInZone(moderatorId!, spaceId!, selectedItem!, widget.zoneId.toString()).then((space) async {

                    setState(() {
                    _fetchWaitersByZoneId(widget.zoneId);
                    listWaiters.removeWhere(
                            (waiter) => waiter.id ==int.parse( _selectedWaiter.toString()));
                    _selectedWaiter=null;
                    });




                  }).catchError((error) {

                  });

                },
           

              ),


            ),
            Expanded(
            child: FutureBuilder(
                future: _fetchWaitersByZoneId(widget.zoneId) ,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return const ItemWaiterShimmer();
                      },
                    );
                  } else if (snapshot.hasError) {
                    return  Center(
                      child: Text( AppLocalizations.of(context)!.errorRetrievingData),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return  Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.group_off_rounded,
                              size: 150,
                              color: gray,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)!.thisZoneHasNoServers,
                              style: const TextStyle(fontSize: 22, color: gray),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {

                    final waiters = snapshot.data!;
                    return ListView.builder(
                        itemCount: waiters.length,
                        itemBuilder: (context, index) {
                          User waiter = waiters[index];


                          return  Column(
                            children: [

                              ItemWaiter(  user: waiter, onDelete: () async {
                                await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomAlertDialog(
                                      title: AppLocalizations.of(context)!.deleteWaiterFromZone,
                                      message: AppLocalizations.of(context)!.confirmWaiterDeletion,
                                      submit: () {
                                        _waitersViewModel.removeServerFromZone(waiter.id!, widget.zoneId).then((space) async {


                                          setState(() {
                                            _fetchWaitersByZoneId(widget.zoneId);
                                            _fetchWaitersBySpaceId();
                                          });
                                          Navigator.of(context).pop();
                                        }).catchError((error) {

                                        });
                                      },
                                      cancel: () {
                                        Navigator.of(context).pop();
                                      },
                                      textSubmitButton: AppLocalizations.of(context)!.delete,
                                      textCancelButton: AppLocalizations.of(context)!.cancel);
                                });
                             },),
                              index!=waiters.length-1?Container(
                                color: lightGray,
                                height: 10,
                              ):SizedBox()
                            ],


                          );



                        });
                  }
                }),
          ),
        ],
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
      ),
    );
  }
}
