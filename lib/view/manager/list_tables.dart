import 'package:dio/dio.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/board.dart';
import 'package:provider/provider.dart';
import '../../models/zone.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../view_model/tables_view_model.dart';
import '../../widgets/custom_app_bar_with_search.dart';
import '../../widgets/input_form.dart';
import '../../widgets/item_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListTables extends StatefulWidget {
  final Zone zone;
  const ListTables({super.key, required this.zone});

  @override
  _ListTablesState createState() => _ListTablesState();
}

class _ListTablesState extends State<ListTables> {
  late final TablesViewModel _tablesViewModel ;
  final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();
  late final TextEditingController _tableNumberController, _nbPlacesController;
  String? errorText;
  bool _isSearching = false;
  String _searchQuery = '';
  @override
  void initState() {
    _tableNumberController = TextEditingController();
    _nbPlacesController = TextEditingController();
    _tablesViewModel = TablesViewModel(context);
    _fetchBoards(widget.zone.id!);
    super.initState();

    // fetch the initial list of zones and update the state
  }

  Future<List<Board>> _fetchBoards(int zoneId) async {
    // fetch the list of categories using
    List<Board> boards = await _tablesViewModel.getBoardByZoneId(zoneId);
    return boards;
  }

  tableDialog(Zone zone, {Board? table}) async {
    setState(() {
      errorText = null; // Set the errorText to display the error message
    });
    if (table != null) {
      _tableNumberController.text = table.numTable.toString();
      _nbPlacesController.text = table.placeNumber.toString();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, refresh) {
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
                          validator: MultiValidator([
                            RequiredValidator(errorText:AppLocalizations.of(context)!.inputRequiredError),
                          ]),
                          controller: _tableNumberController,
                          hint: AppLocalizations.of(context)!.numTable,
                          keyboardType: TextInputType.number,
                        ),
                        errorText != null
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox(),
                        Text(errorText ?? '',
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12)), // Show the error message here
                        const SizedBox(
                          height: 10,
                        ),
                        InputForm(
                          validator: MultiValidator([
                            RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                          ]),
                          controller: _nbPlacesController,
                          hint:AppLocalizations.of(context)!.numPlaces,
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
                  child:  Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(color: Colors.grey),
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
                      if (table == null) {
                        Board table = Board(
                          numTable: numTable,
                          availability: true,
                          placeNumber: nbPlaces,
                        );

                        await _tablesViewModel
                            .addTable(table, zone.id!)
                            .then((table) async {
                          await _tablesViewModel
                              .addBasketByTableId(table.id!.toString())
                              .then((basket) {
                            setState(() {
                              _fetchBoards(zone.id!);
                            });
                            Navigator.of(context).pop();
                          }).catchError((error) {
                            // Handle addBasketByTableId error here
                          });
                        }).catchError((error) {
                          if (error is DioError) {
                            if (error.response?.statusCode == 400) {
                              // Handle 400 status code error (Bad Request)
                              setState(() {
                                errorText = AppLocalizations.of(context)!.tableAlreadyExists;
                              });
                            }
                          } else {
                            // Handle other errors
                            print("Error: $error");
                          }
                        });
                      }
                    else {

                      table.placeNumber=nbPlaces;
                      table.numTable=numTable;
                      await _tablesViewModel
                          .updateTable(table)
                          .then((table) async {



                        Navigator.of(context).pop();

                        refresh(() {
                          _fetchBoards(zone.id!);
                        });

                      }).catchError((error) {
                      });
                    }
                    }
                  },
                  child:  Text(
                    AppLocalizations.of(context)!.confirm,
                    style: const TextStyle(color: orange),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
        backgroundColor: lightGray,
        appBar: CustomAppBarWithSearch(
          title: widget.zone.title,
          isSearching: _isSearching,
          onSearchChanged: (String value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onSearchToggle: () {
            setState(() {
              _isSearching = !_isSearching;
              _searchQuery ='';
            });
          },
          automaticallyImplyLeading: true,
        ),
        floatingActionButton: DraggableFab(
            child: FloatingActionButton(
          onPressed: () {
            tableDialog(widget.zone);
          },
          backgroundColor: orange,
          child: const Icon(Icons.add),
        )),
        body:networkStatus == NetworkStatus.Online
            ? FutureBuilder(
            future: _fetchBoards(widget.zone.id!),
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
                      children:  [
                        const Icon(
                          Icons.table_restaurant_sharp,
                          size: 150,
                          color: gray,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.noTablesInZone,
                          style: const TextStyle(fontSize: 22, color: gray),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                final List<Board> boards;
                if (_searchQuery.isEmpty) {
                  boards = snapshot.data!;
                } else {
                  boards = (snapshot.data! as List<Board>)
                      .where((board) =>  "${AppLocalizations.of(context)!.table} ${board.numTable}"
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                      .toList();
                }
                return ListView.builder(
                    itemCount: boards.length,
                    itemBuilder: (context, index) {
                      final board = boards[index];

                      return Column(
                        children: [
                          ItemTable(
                            table: board,
                            zone: widget.zone,
                            onDelete: () {
                              _tablesViewModel
                                  .deleteTable(board.id!)
                                  .then((_) async {
                                setState(() {
                                  _fetchBoards(widget.zone.id!);
                                });
                              }).catchError((error) {
                                print(error);
                              });
                            },
                            onUpdate: () {
                              tableDialog(widget.zone, table: board);
                            },
                          ),
                          index != boards.length - 1
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
