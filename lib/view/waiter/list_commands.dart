import 'package:flutter/material.dart';
import 'package:hello_way/models/command.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/response/command_with_num_table.dart';
import 'package:hello_way/shimmer/item_command_shimmer.dart';
import 'package:hello_way/utils/const.dart';
import 'package:hello_way/widgets/command_status_tab_bar.dart';
import 'package:provider/provider.dart';

import '../../services/network_service.dart';
import '../../view_model/commands_view_model.dart';
import '../../widgets/item_command.dart';
import 'command_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListCommands extends StatefulWidget {
  const ListCommands({super.key});

  @override
  State<ListCommands> createState() => _ListCommandsState();
}

class _ListCommandsState extends State<ListCommands> {
  late CommandsViewModel _listCommandsViewModel;
  int selectedStatusIndex = 0;
  String status = "ALL";

  Future<List<CommandWithNumTable>> getCommandsByWaiterId(String status) async {
    List<CommandWithNumTable> products =
        await _listCommandsViewModel.getCommandsByWaiterId(status);
    return products;
  }

  Future<double> getSumOfCommand(int commandId) async {
    double sum = await _listCommandsViewModel.getSumOfCommand(commandId);
    return sum;
  }
  @override
  void initState() {
    // TODO: implement initState
    _listCommandsViewModel = CommandsViewModel(context);
    getCommandsByWaiterId( status);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final listOrdersStatus = initListOrdersStatus(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.orderList),
      ),
      body: networkStatus == NetworkStatus.Online
          ?Column(
        children: [
          CommandStatusTabBar(
            onChanged: (index) {
              switch (index) {
                case 0:
                  status = "ALL";
                  break;
                case 1:
                  status = "NOT_YET";
                  break;
                case 2:
                  status = "CONFIRMED";
                  break;
                default:
                  status = "ALL";
                  break;
              }
              setState(() {
                selectedStatusIndex = index;
              });
            },
            selectedIndex: selectedStatusIndex,
            items: listOrdersStatus,
          ),
          Expanded(
            child: FutureBuilder(
              future: getCommandsByWaiterId(status),
              builder: (BuildContext context,
                  AsyncSnapshot<List<CommandWithNumTable>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    itemCount: 10,
                    separatorBuilder: (context, index) =>  Container(color:lightGray,height: 10),
                    itemBuilder: (context, index) {
                      return const ItemCommandShimmer() ;
                    },
                  );
                } else if (snapshot.hasError) {
                  return  Center(
                    child: Text(AppLocalizations.of(context)!.errorRetrievingData),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center();
                } else {
                  final commands = snapshot.data!;
                  return ListView.separated(
                    itemCount: commands.length,
                    itemBuilder: (context, index) {
                      CommandWithNumTable commandWithNumTable = commands[index];
                      return FutureBuilder(
                        future: getSumOfCommand(
                            commandWithNumTable.command.idCommand),
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
                            return GestureDetector(
                              child: ItemCommand(
                                commandWithNumTable: commandWithNumTable,
                                sum: sum,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommandDetails(
                                      commandWithNumTable: commandWithNumTable,
                                    ),
                                  ),
                                ).then((user) {
                                  setState(() {
                                    getCommandsByWaiterId("ALL");
                                    getSumOfCommand(commandWithNumTable.command.idCommand);
                                  });
                                }).catchError((error) {
                                  print(error);
                                });
                              },
                            );
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
              },
            ),
          )
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
    );
  }
}
