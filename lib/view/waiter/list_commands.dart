import 'package:flutter/material.dart';
import 'package:hello_way/models/command.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/response/command_with_num_table.dart';
import 'package:hello_way/shimmer/item_command_shimmer.dart';
import 'package:hello_way/utils/const.dart';
import 'package:hello_way/widgets/command_status_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    _listCommandsViewModel = CommandsViewModel(context);
    _initializeWebSocket();
    getCommandsByWaiterId(status);
  }

  void _initializeWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws:$Url/ws/commands'),
    );

    channel.stream.listen((message) {
      setState(() {
        getCommandsByWaiterId(status);
      });
    });
  }

  Future<List<CommandWithNumTable>> getCommandsByWaiterId(String status) async {
    return await _listCommandsViewModel.getCommandsByWaiterId(status);
  }

  Future<double> getSumOfCommand(int commandId) async {
    return await _listCommandsViewModel.getSumOfCommand(commandId);
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
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
          ? Column(
        children: [
          CommandStatusTabBar(
            onChanged: (index) {
              setState(() {
                selectedStatusIndex = index;
                status = _mapIndexToStatus(index);
                getCommandsByWaiterId(status);
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
                  return _buildLoadingList();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.errorRetrievingData),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.noOrdersAvailable),
                  );
                } else {
                  final commands = snapshot.data!;
                  return ListView.separated(
                    itemCount: commands.length,
                    itemBuilder: (context, index) {
                      return _buildCommandCard(commands[index]);
                    },
                    separatorBuilder: (context, index) => Divider(color: lightGray),
                  );
                }
              },
            ),
          )
        ],
      )
          : _buildOfflineUI(context),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => Divider(color: lightGray),
      itemBuilder: (context, index) => const ItemCommandShimmer(),
    );
  }

  Widget _buildCommandCard(CommandWithNumTable commandWithNumTable) {
    return FutureBuilder(
      future: getSumOfCommand(commandWithNumTable.command.idCommand),
      builder: (BuildContext context, AsyncSnapshot<double> sumSnapshot) {
        if (sumSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (sumSnapshot.hasError) {
          return Text(AppLocalizations.of(context)!.errorRetrievingData);
        } else {
          final sum = sumSnapshot.data ?? 0.0;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommandDetails(
                    commandWithNumTable: commandWithNumTable,
                  ),
                ),
              ).then((_) => setState(() => getCommandsByWaiterId("ALL")));
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commandWithNumTable.command.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Total: \$${sum.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.receipt_long,
                      color: orange,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildOfflineUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
              style: const TextStyle(fontSize: 18, color: gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            MaterialButton(
              color: orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () => setState(() {}),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mapIndexToStatus(int index) {
    switch (index) {
      case 1:
        return "NOT_YET";
      case 2:
        return "CONFIRMED";
      case 3:
        return "UPDATED";
      case 4:
        return "PAYED";
      default:
        return "ALL";
    }
  }
}
