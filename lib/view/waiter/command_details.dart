import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../res/app_colors.dart';
import '../../response/command_with_num_table.dart';
import '../../response/product_with_quantities.dart';
import '../../services/network_service.dart';
import '../../shimmer/item_product_command_shimmer.dart';
import '../../view_model/commands_view_model.dart';
import '../../widgets/item_product_command.dart';
import '../../widgets/snack_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommandDetails extends StatefulWidget {
  final CommandWithNumTable commandWithNumTable;

  const CommandDetails(
      {super.key, required this.commandWithNumTable,});

  @override
  State<CommandDetails> createState() => _CommandDetailsState();
}

class _CommandDetailsState extends State<CommandDetails> {
  late final CommandsViewModel _commandsViewModel;

  final GlobalKey<ScaffoldMessengerState> _detailsCommandScaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  double? _sum;





  Future<List<ProductWithQuantities>> _getProductsByCommandId() async {
    List<ProductWithQuantities> products = await _commandsViewModel
        .getProductsByCommandId(widget.commandWithNumTable.command.idCommand);
    return products;
  }

  Future<double> getSumOfCommand(int commandId) async {
    double sum = await _commandsViewModel.getSumOfCommand(commandId);

    return sum;
  }
  @override
  void initState() {
    _commandsViewModel = CommandsViewModel(context);
    _getProductsByCommandId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return ScaffoldMessenger(
        key: _detailsCommandScaffoldKey,
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        title: Text(
          "${AppLocalizations.of(context)!.order} N°${widget.commandWithNumTable.command.idCommand}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body:networkStatus == NetworkStatus.Online
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.order} N°${widget.commandWithNumTable.command.idCommand} - ${AppLocalizations.of(context)!.table} N°${widget.commandWithNumTable.numTable}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(widget.commandWithNumTable.command.status=="CONFIRMED")
                    FutureBuilder(
                    future: getSumOfCommand(widget.commandWithNumTable.command.idCommand),
                    builder: (BuildContext context,
                    AsyncSnapshot<double> sumSnapshot) {
                    if (sumSnapshot.connectionState ==
                    ConnectionState.waiting) {
                    return const SizedBox
                        .shrink(); // or a loading widget
                    } else if (sumSnapshot.hasError) {
                    return  Text(AppLocalizations.of(context)!.errorRetrievingData);
                    } else {
                    final sum = sumSnapshot.data!;



                    return Text(
                      "${AppLocalizations.of(context)!.total}: $sum",
                      style: const TextStyle(fontSize: 16),
                    );}}),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.commandWithNumTable.command.status ==
                                "NOT_YET"
                            ? Colors.orangeAccent
                            : widget.commandWithNumTable.command.status ==
                                    "REFUSED"
                                ? Colors.red
                                : Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.commandWithNumTable.command.status == "NOT_YET"
                            ?AppLocalizations.of(context)!.pendingStatus
                            : widget.commandWithNumTable.command.status ==
                                    "REFUSED"
                                ? AppLocalizations.of(context)!.refusedStatus
                                : widget.commandWithNumTable.command.status ==
                                        "CONFIRMED"
                                    ?AppLocalizations.of(context)!.confirmedStatus
                                    : AppLocalizations.of(context)!.payedStatus,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: lightGray,
            height: 10,
          ),
          Expanded(
            child: FutureBuilder(
                future: _getProductsByCommandId(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return const ItemProductCommandShimmer();
                      },
                    );
                  } else if (snapshot.hasError) {
                    return  Center(
                      child: Text(AppLocalizations.of(context)!.errorRetrievingData),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center();
                  } else {
                    final products = snapshot.data!;
                    return ListView.separated(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        ProductWithQuantities productWithQuantities =
                            products[index];

                        return ItemProductCommand(
                          productWithQuantities: productWithQuantities,
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
                }),
          ),
          if (widget.commandWithNumTable.command.status == "NOT_YET")
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
                            color: orange,
                          ),
                          child: MaterialButton(
                            height: 50,
                            onPressed: () {
                              _commandsViewModel
                                  .acceptCommand(widget
                                      .commandWithNumTable.command.idCommand)
                                  .then((_) async {

                                setState(() {
                                  widget.commandWithNumTable.command.status =
                                  "CONFIRMED";
                                });
                                var snackBar =  customSnackBar(context, AppLocalizations.of(context)!.orderConfirmed, Colors.green);
                                _detailsCommandScaffoldKey.currentState?.showSnackBar(snackBar);
                              }).catchError((error) {});
                            },
                            child:  Text(
                              AppLocalizations.of(context)!.confirmOrder,
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
                          _commandsViewModel
                              .refuseCommand(widget
                              .commandWithNumTable.command.idCommand)
                              .then((_) async {

                            setState(() {
                              widget.commandWithNumTable.command.status =
                              "REFUSED";
                            });
                            var snackBar =  customSnackBar(context, AppLocalizations.of(context)!.orderRefused, Colors.green);
                            _detailsCommandScaffoldKey.currentState?.showSnackBar(snackBar);
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
          if (widget.commandWithNumTable.command.status == "CONFIRMED")
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0), color: orange),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: MaterialButton(
                    onPressed: () {
                      _commandsViewModel
                          .payCommand(widget
                          .commandWithNumTable.command.idCommand)
                          .then((_) async {

                        setState(() {
                          widget.commandWithNumTable.command.status =
                          "PAYED";
                        });
                        var snackBar =  customSnackBar(context, AppLocalizations.of(context)!.orderPaid, Colors.green);
                        _detailsCommandScaffoldKey.currentState?.showSnackBar(snackBar);
                      }).catchError((error) {});
                    },
                    child: Text(
                      '${AppLocalizations.of(context)!.payOrder}  ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
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
