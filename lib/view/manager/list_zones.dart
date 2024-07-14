import 'dart:async';
import 'package:dio/dio.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/zone.dart';
import 'package:hello_way/view/manager/list_waiters_by_zone.dart';
import 'package:provider/provider.dart';
import '../../models/board.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../shimmer/item_zone_shimmer.dart';
import '../../utils/routes.dart';
import '../../view_model/tables_view_model.dart';
import '../../view_model/zones_view_model.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../../widgets/custom_app_bar_with_search.dart';
import '../../widgets/dialog.dart';
import '../../widgets/input_form.dart';
import '../../widgets/my_dialog.dart';
import '../../widgets/item_zone.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListZones extends StatefulWidget {
  @override
  _ListZonesState createState() => _ListZonesState();
}

class _ListZonesState extends State<ListZones> {
  late ZonesViewModel _zonesViewModel;
  late final TablesViewModel _addTableViewModel;
  late final TextEditingController _tableNumberController,
      _nbPlacesController,
      _titleZoneController;
  final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _zonesScaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  bool _isSearching = false;
  String _searchQuery = '';
  String? errorText;

  @override
  void initState() {
    _zonesViewModel = ZonesViewModel(context);
    _addTableViewModel = TablesViewModel(context);
    _tableNumberController = TextEditingController();
    _nbPlacesController = TextEditingController();
    _titleZoneController = TextEditingController();
    _fetchZones();
    super.initState();
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _nbPlacesController.dispose();
    _titleZoneController.dispose();
    super.dispose();
  }

  String? _validation(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    } else if (errorText != null) {
      return errorText;
    }
    return null;
  }

  Future<List<Zone>> _fetchZones() async {
    List<Zone> zones = await _zonesViewModel.getZonesByIdSpace();
    return zones;
  }

  String? _validateZoneTitle(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    } else if (errorText != null) {
      return AppLocalizations.of(context)!.zoneAlreadyExists;
    }
    // Regex to allow only alphabets, numbers, spaces, and underscores
    RegExp regExp = RegExp(r'^[a-zA-Z0-9 _]*$');
    if (!regExp.hasMatch(value)) {
      return 'Invalid characters';
    }
    return null;
  }

  Future<void> _addOrUpdateZone() async {
    String zoneTitle = _titleZoneController.text.trim();
    String normalizedZoneTitle =
    zoneTitle.replaceAll(' ', '').replaceAll('_', '').toLowerCase();

    List<Zone> existingZones = await _fetchZones();
    bool zoneExists = existingZones.any((zone) =>
    zone.title.replaceAll(' ', '').replaceAll('_', '').toLowerCase() ==
        normalizedZoneTitle);

    if (zoneExists) {
      setState(() {
        errorText = AppLocalizations.of(context)!.zoneAlreadyExists;
      });
    } else {
      Zone zone = Zone(title: zoneTitle);
      await _zonesViewModel.addZoneByIdSpace(zone).then((_) {
        Navigator.of(context).pop();
        setState(() {
          _fetchZones();
        });
      }).catchError((error) {
        if (error is DioError) {
          if (error.response?.statusCode == 400) {
            setState(() {
              errorText = AppLocalizations.of(context)!.zoneAlreadyExists;
            });
          }
        } else {
          print("Error: $error");
        }
      });
    }
  }

  Future<void> addTable(Zone zone) async {
    if (zone.server != null) {
      errorText = null; // Set the errorText to display the error message

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, update) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.addNewTableTitle),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.addNewTableMessage),
                    const SizedBox(height: 20),
                    Form(
                      key: _dialogFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputForm(
                            validator: _customValidator,
                            controller: _tableNumberController,
                            hint: AppLocalizations.of(context)!.numTable,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputForm(
                            validator: _customValidator,
                            controller: _nbPlacesController,
                            hint: AppLocalizations.of(context)!.numPlaces,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: orange),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_dialogFormKey.currentState!.validate()) {
                        _dialogFormKey.currentState!.save();
                        int numTable =
                        int.parse(_tableNumberController.text.toString());
                        int nbPlaces =
                        int.parse(_nbPlacesController.text.toString());
                        Board table = Board(
                          numTable: numTable,
                          availability: true,
                          placeNumber: nbPlaces,
                        );

                        await _addTableViewModel
                            .addTable(table, zone.id!)
                            .then((table) async {
                          await _addTableViewModel
                              .addBasketByTableId(table.id!.toString())
                              .then((basket) {
                            Navigator.of(context).pop();
                          }).catchError((error) {
                            // Handle addBasketByTableId error here
                          });
                        }).catchError((error) {
                          if (error is DioError) {
                            if (error.response?.statusCode == 400) {
                              update(() {
                                errorText = AppLocalizations.of(context)!
                                    .tableAlreadyExists;
                              });
                            }
                          } else {
                            print("Error: $error");
                          }
                        });
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: TextStyle(color: orange),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListWaitersByZone(zoneId: zone.id!, zone: zone),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacementNamed(context, managerBottomNavigationRoute);
      return true;
    },
    child: ScaffoldMessenger(
      key: _zonesScaffoldKey,
      child: Scaffold(
        backgroundColor: lightGray,
        appBar: CustomAppBarWithSearch(
          title: AppLocalizations.of(context)!.myZones,
          isSearching: _isSearching,
          onSearchChanged: (String value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onSearchToggle: () {
            setState(() {
              _isSearching = !_isSearching;
              _searchQuery = '';
            });
          },
          automaticallyImplyLeading: true,
        ),
        floatingActionButton: DraggableFab(
          child: FloatingActionButton(
            backgroundColor: orange,
            onPressed: () async {
              _titleZoneController.clear();
              errorText = null;
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, update) {
                      return MyDialogue(
                        title: AppLocalizations.of(context)!.addZone,
                        validator: _validateZoneTitle,
                        controller: _titleZoneController,
                        submit: _addOrUpdateZone,
                        cancel: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              );
              _titleZoneController.clear();
            },
            child: const Icon(Icons.add),
          ),
        ),
        body: networkStatus == NetworkStatus.Online
            ? FutureBuilder(
          future: _fetchZones(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                itemCount: 10,
                separatorBuilder: (context, index) =>
                    Container(color: lightGray, height: 10),
                itemBuilder: (context, index) {
                  return ItemZoneShimmer();
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                    AppLocalizations.of(context)!.errorRetrievingData),
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
                        Icons.group_work_outlined,
                        size: 150,
                        color: gray,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.noZonesInSpace,
                        style:
                        const TextStyle(fontSize: 22, color: gray),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              final List<Zone> zones;
              if (_searchQuery.isEmpty) {
                zones = snapshot.data!;
              } else {
                zones = (snapshot.data! as List<Zone>)
                    .where((zone) => zone.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                    .toList();
              }
              return ListView.separated(
                itemCount: zones.length,
                itemBuilder: (context, index) {
                  Zone zone = zones[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListWaitersByZone(
                            zoneId: zone.id!,
                            zone: zone!,
                          ),
                        ),
                      );
                    },
                    child: ItemZone(
                      zone: zone,
                      onDelete: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomAlertDialog(
                              title: AppLocalizations.of(context)!
                                  .deleteZoneDialogTitle,
                              message: AppLocalizations.of(context)!
                                  .deleteZoneMessage,
                              submit: () {
                                _zonesViewModel
                                    .deleteZone(zone.id!)
                                    .then((_) async {
                                  setState(() {
                                    _fetchZones();
                                  });
                                  Navigator.of(context).pop();
                                }).catchError((error) {
                                  print(error);
                                });
                              },
                              cancel: () {
                                Navigator.of(context).pop();
                              },
                              textSubmitButton:
                              AppLocalizations.of(context)!.delete,
                              textCancelButton:
                              AppLocalizations.of(context)!.cancel,
                            );
                          },
                        );
                      },
                      onUpdate: () async {
                        errorText = null;
                        _titleZoneController.text = zone.title;
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, update) {
                                return CustomDialog(
                                  title: AppLocalizations.of(context)!
                                      .renameZone,
                                  validator: _validation,
                                  controller: _titleZoneController,
                                  hint: AppLocalizations.of(context)!
                                      .title,
                                  keyboardType: TextInputType.text,
                                  message: AppLocalizations.of(context)!
                                      .renameZoneMessage,
                                  submit: () {
                                    zone.title = _titleZoneController.text.trim();
                                    _zonesViewModel.updateZone(zone).then((_) async {
                                      setState(() {
                                        _fetchZones();
                                      });
                                      Navigator.of(context).pop();
                                    }).catchError((error) {
                                      if (error is DioError) {
                                        if (error.response?.statusCode == 400) {
                                          update(() {
                                            errorText = AppLocalizations.of(context)!.zoneAlreadyExists;
                                          });
                                        }
                                      } else {
                                        print("Error: $error");
                                      }
                                    });
                                  },
                                  cancel: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                      onAdd: () {
                        addTable(zone);
                      },
                    ),
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
        )
            : Center(
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
                SizedBox(height: 10),
                MaterialButton(
                  color: orange,
                  height: 40,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text(
                    AppLocalizations.of(context)!.retry,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }

  String? _customValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      // Check if the value contains a dot (.) or comma (,)
      if (value.contains('.') || value.contains(',')) {
        return AppLocalizations.of(context)!.dotsOrcommasError;
      }

      int? numberOfParticipants = int.tryParse(value);
      if (numberOfParticipants == null) {
        return AppLocalizations.of(context)!.inputRequiredError;
      } else if (numberOfParticipants < 0) {
        return AppLocalizations.of(context)!.nigativeError;
      }
    }
    return null;
  }
}
