

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../response/command_with_num_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemCommand extends StatefulWidget {
  final CommandWithNumTable commandWithNumTable;
  final double sum;
  const ItemCommand({
    super.key,
    required this.commandWithNumTable, required this.sum,
  });

  @override
  State<ItemCommand> createState() => _ItemCommandState();
}

class _ItemCommandState extends State<ItemCommand> {

  @override
  void initState() {

    super.initState();
  }




  @override
  Widget build(BuildContext context) {

    return Container(
        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.order}N°${widget.commandWithNumTable.command.idCommand} - ${AppLocalizations.of(context)!.table} N°${widget.commandWithNumTable.numTable}",
                    style: const TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5,),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:widget.commandWithNumTable.command.status=="NOT_YET"? Colors.orangeAccent:Colors.green,
                    ),
                  ),
                ],
              ),

            ],
          ),
          const SizedBox(height: 10,),
          if(widget.commandWithNumTable.command.status=="CONFIRMED")
          Text("${AppLocalizations.of(context)!.total}: ${widget.sum} ${AppLocalizations.of(context)!.tunisianDinar}"   ,style: const TextStyle(
              fontSize: 16))

        ]));
  }
}
