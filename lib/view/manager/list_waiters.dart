import 'dart:io';
import 'dart:typed_data';

import 'package:draggable_fab/draggable_fab.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/shimmer/item_waiter_shimmer.dart';
import 'package:hello_way/view/manager/waiter_details.dart';
import 'package:hello_way/widgets/item_waiter.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/network_service.dart';
import '../../utils/const.dart';
import '../../utils/routes.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/waiters_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/custom_alert_dialog.dart';

class ListWaiters extends StatefulWidget {
  const ListWaiters({Key? key}) : super(key: key);

  @override
  State<ListWaiters> createState() => _ListWaitersState();
}

class _ListWaitersState extends State<ListWaiters> {
  late WaitersViewModel _waitersViewModel;
  final SecureStorage secureStorage = SecureStorage();
  Uint8List? pdf;
  bool _isSearching = false;
  String _searchQuery = '';
  Future<List<User>> _fetchWaitersBySpaceId() async {
    // fetch the list of categories using
    List<User> waiters = await _waitersViewModel.getWaitersBySpaceId();
    return waiters;
  }

  Future<void> _fetchPdf() async {
    final spaceId = await secureStorage.readData(spaceIdKey);

    Uint8List data = await _waitersViewModel.fetchPdf(int.parse(spaceId!));
    setState(() {
      pdf = data;
    });
  }

  Future<void> _downloadPdf(Uint8List pdfBytes) async {
    try {

        String fileName = 'Servers';



        print(pdfBytes);
        await FileSaver.instance.saveAs(
          name: fileName,
          bytes: pdfBytes,
          mimeType: MimeType.pdf,
          ext: 'pdf',
        );

        // Display a success message or perform other actions after the download
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text( AppLocalizations.of(context)!.pdfDownloadedSuccessfully),
              backgroundColor: Colors.green),
        );
    } catch (error) {
      // Handle any errors that occur during the download process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text( AppLocalizations.of(context)!.errorDownloadingPdf),
        ),
      );
    }
  }

  @override
  void initState() {
    _waitersViewModel = WaitersViewModel(context);
    _fetchPdf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            : Text(AppLocalizations.of(context)!.waitersList),
        elevation: 1,
        actions: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
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
                    icon: const Icon(Icons.file_download),
                    onPressed: () async {
                      _downloadPdf(pdf!);
                    },
                  ),
                ],
              ))
        ],
      ),
      body:networkStatus == NetworkStatus.Online
          ? FutureBuilder(
          future: _fetchWaitersBySpaceId(),
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
                child: Text(AppLocalizations.of(context)!.errorRetrievingData),
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
                        AppLocalizations.of(context)!.yourSpaceHasNoServers,
                        style: const TextStyle(fontSize: 22, color: gray),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            } else {

              final List<User> waiters;
              if (_searchQuery.isEmpty) {
                waiters = snapshot.data!;
              } else {
                waiters = (snapshot.data! as List<User>)
                    .where((user) =>user.name!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    user.lastname!.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();
              }
              return ListView.builder(
                  itemCount: waiters.length,
                  itemBuilder: (context, index) {
                    final waiter = waiters[index];

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WaiterDetails(
                                  waiter: waiter,
                                ),
                              ),
                            );
                          },
                          child: ItemWaiter(
                            user: waiter,
                            onDelete: () async {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomAlertDialog(
                                        title: AppLocalizations.of(context)!
                                            .deleteWaiterDialogTitle,
                                        message: AppLocalizations.of(context)!
                                            .deleteWaiterMessage,
                                        submit: () async {
                                          await _waitersViewModel
                                              .deleteWaiter(waiter.id!)
                                              .then((_) async {
                                            setState(() {
                                              _fetchWaitersBySpaceId();
                                            });
                                            Navigator.of(context).pop();
                                          }).catchError((error) {});
                                        },
                                        cancel: () {
                                          Navigator.of(context).pop();
                                        },
                                        textSubmitButton:
                                            AppLocalizations.of(context)!
                                                .delete,
                                        textCancelButton:
                                            AppLocalizations.of(context)!
                                                .cancel);
                                  });
                            },
                          ),
                        ),
                        index != waiters.length - 1
                            ? Container(
                                color: lightGray,
                                height: 10,
                              )
                            : const SizedBox()
                      ],
                    );
                  });
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
      floatingActionButton: DraggableFab(
          child: FloatingActionButton(
        onPressed: () async {
          final resultat=await Navigator.pushNamed(context, addWaiterRoute);
          if(resultat!=null){

            setState(() {
              _fetchWaitersBySpaceId();
            });
          }
        },
        backgroundColor: orange,
        child: const Icon(Icons.person_add),
      )),
    );
  }
}
