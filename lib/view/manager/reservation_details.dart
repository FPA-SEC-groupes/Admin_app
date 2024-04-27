import 'package:flutter/material.dart';
import 'package:hello_way/models/reservation.dart';
import 'package:hello_way/widgets/snack_bar.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import '../../models/board.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../view_model/reservations_view_model.dart';
import '../../view_model/tables_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ReservationDetails extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetails({
    super.key,
    required this.reservation,
  });

  @override
  State<ReservationDetails> createState() => _ReservationDetailsState();
}

class _ReservationDetailsState extends State<ReservationDetails> {
  late ReservationsViewModel _reservationsViewModel;
  final GlobalKey<ScaffoldMessengerState> _reservationDetailsScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late final TablesViewModel _tablesViewModel;
  List<Board> tables = [];
  List<Board> assignedTables = [];
  @override
  void initState() {
    super.initState();
    _tablesViewModel = TablesViewModel(context);
    _reservationsViewModel = ReservationsViewModel(context);
    if(widget.reservation.status == "NOT_YET" ){
      _fetchBoards(formatDateToIso(widget.reservation.startDate));
    }else{
      _fetchTablesByIdReservation(widget.reservation.idReservation!);
    }

  }

  String formatDateToIso(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  Future<List<Board>> _fetchBoards(String date) async {
    // fetch the list of categories using
    List<Board> boards =
        await _tablesViewModel.getTablesByDisponibilities(date);
    setState(() {
      tables = boards;
      _items = tables
          .map((table) => MultiSelectItem<Board>(
              table, "${AppLocalizations.of(context)!.table}${table.numTable} (${table.placeNumber}${AppLocalizations.of(context)!.places})"))
          .toList();
    });
    return boards;
  }

  Future<List<Board>> _fetchTablesByIdReservation(int reservationId) async {
    // fetch the list of categories using
    List<Board> boards =
        await _tablesViewModel.getTablesByReservationId(reservationId);
    setState(() {
      assignedTables = boards;
    });
    return boards;
  }

  List<MultiSelectItem<Board>> _items = [];

  List<Board> _selectedTables = [];

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return ScaffoldMessenger(
        key: _reservationDetailsScaffoldKey,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: orange,
            title: Text(
              "${AppLocalizations.of(context)!.reservation} N°${widget.reservation.idReservation}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body:networkStatus == NetworkStatus.Online
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.reservation} N°${widget.reservation.idReservation}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: widget.reservation.status == "NOT_YET"
                                  ? Colors.orangeAccent
                                  : widget.reservation.status == "CONFIRMED"
                                      ? Colors.green
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              widget.reservation.status == "NOT_YET"
                                  ? AppLocalizations.of(context)!.pendingStatus
                                  : widget.reservation.status == "REFUSED"
                                      ? AppLocalizations.of(context)!.refusedStatus
                                      : widget.reservation.status == "CONFIRMED"
                                          ? AppLocalizations.of(context)!.confirmedStatus
                                          :AppLocalizations.of(context)!.canceledStatus,
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          widget.reservation.eventTitle
                                  .substring(0, 1)
                                  .toUpperCase() +
                              widget.reservation.eventTitle.substring(1),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(widget.reservation.startDate.toString(),
                          style: const TextStyle(color: gray, fontSize: 16)),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        color: lightGray,
                        height: 10,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                             TextSpan(
                              text:"${AppLocalizations.of(context)!.numberOfGuests}:",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text:
                                  "${widget.reservation.numberOfGuests}${AppLocalizations.of(context)!.people}",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                       Text("${AppLocalizations.of(context)!.description}:",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                          widget.reservation.description!
                                  .substring(0, 1)
                                  .toUpperCase() +
                              widget.reservation.description!.substring(1),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(
                        height: 10,
                      ),
                       Text("${AppLocalizations.of(context)!.tables}:",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 10,
                      ),
                      if (widget.reservation.status == "NOT_YET")
                        MultiSelectDialogField(
                          items: _items,
                          title: Text(AppLocalizations.of(context)!.selectTables),
                          selectedColor: orange,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                              color: orange,
                              width: 1,
                            ),
                          ),
                          buttonIcon: const Icon(
                            Icons.table_restaurant_sharp,
                            color: Colors.orange,
                          ),
                          buttonText:  Text(
                            AppLocalizations.of(context)!.assignTables,
                            style: const TextStyle(
                              color: gray,
                              fontSize: 16,
                            ),
                          ),
                          onConfirm: (results) {
                            setState(() {
                              _selectedTables = results;
                            });

                            print(_selectedTables);
                          },
                        ),
                      if (widget.reservation.status != "NOT_YET" && assignedTables.isNotEmpty)
                        Expanded(
                            child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing: 10.0, // Spacing between columns
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 4.5, // Spacing between rows
                          ),
                          itemCount: assignedTables.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                color: Colors.orange.withOpacity(0.4),
                              ),
                              child: Center(
                                child: Text(
                                  "${AppLocalizations.of(context)!.table}${assignedTables[index].numTable}(${assignedTables[index].placeNumber} ${AppLocalizations.of(context)!.places})",
                                  style: TextStyle(fontSize: 16, color: orange),
                                ),
                              ),
                            );
                          },
                        )),
                    ],
                  ),
                ),
              ),
              if (widget.reservation.status == "NOT_YET")
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color:
                                    _selectedTables.length == 0 ? gray : orange,
                              ),
                              child: MaterialButton(
                                height: 50,
                                onPressed: () {
                                  List<int> boardIds = [];
                                  if (_selectedTables.length != 0) {
                                    for (var table in _selectedTables) {
                                      boardIds.add(table.id!);
                                    }

                                    _reservationsViewModel
                                        .assignReservationToTables(boardIds,
                                            widget.reservation.idReservation!)
                                        .then((reservation) async {
                                      _reservationsViewModel
                                          .acceptReservation(
                                              widget.reservation.idReservation!)
                                          .then((reservation) async {
                                        if (reservation != null) {
                                          setState(() {
                                            widget.reservation.status =
                                                "CONFIRMED";
                                          });
                                          _fetchTablesByIdReservation(widget.reservation.idReservation!);
                                          var snackBar = customSnackBar(
                                              context,
                                             AppLocalizations.of(context)!.reservationConfirmed,
                                              Colors.green);
                                          _reservationDetailsScaffoldKey
                                              .currentState
                                              ?.showSnackBar(snackBar);
                                        }
                                      }).catchError((error) {});
                                    }).catchError((error) {});
                                  }
                                },
                                child:  Text(
    AppLocalizations.of(context)!.confirmReservation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          InkWell(
                            onTap: () {
                              _reservationsViewModel
                                  .refuseReservation(
                                      widget.reservation.idReservation!)
                                  .then((reservation) async {
                                if (reservation != null) {
                                  setState(() {
                                    widget.reservation.status = "REFUSED";
                                  });
                                  var snackBar = customSnackBar(context,
                                      'Reservation refusée ', Colors.green);
                                  _reservationDetailsScaffoldKey.currentState
                                      ?.showSnackBar(snackBar);
                                }
                              }).catchError((error) {});
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: gray,
                                    width: 2.0,
                                  )),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: gray,
                                  size: 30.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
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
        ));
  }
}
