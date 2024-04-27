import 'dart:async';

import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';

import 'package:hello_way/utils/routes.dart';
import 'package:hello_way/view/manager/add_primary_material.dart';
import 'package:hello_way/widgets/item_primary_material.dart';
import 'package:provider/provider.dart';
import '../../models/primary_material.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../shimmer/item_zone_shimmer.dart';
import '../../view_model/stock_view_model.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../../widgets/custom_app_bar_with_search.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Stock extends StatefulWidget {
  const Stock({super.key});

  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {
  late final StockViewModel _stockViewModel ;
  final TextEditingController _titleZoneController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _stockViewModel = StockViewModel(context);
    _getStockBySpaceId();
  }

  Future<List<PrimaryMaterial>> _getStockBySpaceId() async {
    // fetch the list of categories using
    List<PrimaryMaterial> stock =
        await _stockViewModel.getPrimaryMaterialsByIdSpace();
    return stock;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleZoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
        backgroundColor: lightGray,
        appBar: CustomAppBarWithSearch(
          title: AppLocalizations.of(context)!.myStock,
          isSearching: _isSearching,
          onSearchChanged: (String value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onSearchToggle: () {
            setState(() {
              _isSearching = !_isSearching;
            });
          },
          automaticallyImplyLeading: true,
        ),
        floatingActionButton: DraggableFab(
          child: FloatingActionButton(
            backgroundColor: orange,
            onPressed: () async {

              final resultat=await Navigator.pushNamed(context, addPrimaryMaterialRoute);
              if(resultat!=null){

                setState(() {
                  _getStockBySpaceId();
                });
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
        body:networkStatus == NetworkStatus.Online
            ? FutureBuilder(
            future: _getStockBySpaceId(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  itemCount: 10,
                  separatorBuilder: (context, index) =>
                      Container(color: lightGray, height: 10),
                  itemBuilder: (context, index) {
                    return const ItemZoneShimmer();
                  },
                );
              } else if (snapshot.hasError) {
                return  Center(
                  child: Text(AppLocalizations.of(context)!.errorRetrievingData),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        const Icon(
                          Icons.clear_outlined,
                          size: 150,
                          color: gray,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.stockEmpty,
                          style: const TextStyle(fontSize: 22, color: gray),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                final List<PrimaryMaterial> stock;
                if (_searchQuery.isEmpty) {
                  stock = snapshot.data!;
                } else {
                  stock = (snapshot.data! as List<PrimaryMaterial>)
                      .where((primaryMaterial) => primaryMaterial.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                }
                return ListView.separated(
                  itemCount: stock.length,
                  itemBuilder: (context, index) {
                    PrimaryMaterial primaryMaterial = stock[index];

                    return ItemPrimaryMaterial(
                      primaryMaterial: primaryMaterial,
                      onDelete: () async {
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomAlertDialog(
                                  title: AppLocalizations.of(context)!
                                      .deleteFromStockDialogTitle,
                                  message: AppLocalizations.of(context)!
                                      .deleteFromStockMessage,
                                  submit: () async {
                                    await _stockViewModel
                                        .removePrimaryMaterialFromSpace(
                                            primaryMaterial.id!)
                                        .then((space) async {
                                      setState(() {
                                        _getStockBySpaceId();
                                      });

                                      Navigator.of(context).pop();
                                    }).catchError((error) {});
                                  },
                                  cancel: () {
                                    Navigator.of(context).pop();
                                  },
                                  textSubmitButton:
                                      AppLocalizations.of(context)!.delete,
                                  textCancelButton:
                                      AppLocalizations.of(context)!.cancel);
                            });
                      },
                      onUpdate: () async {
                        final resultat=await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPrimaryMaterial(
                              primaryMaterial: primaryMaterial,
                            ),
                          ),
                        );
                        if(resultat!=null){

                          setState(() {
                          _getStockBySpaceId();
                          });
                        }
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
