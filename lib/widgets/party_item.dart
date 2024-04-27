import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way/models/event.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:intl/intl.dart';

import '../utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef ActionPopUpItemSelectedCallback = Future<void> Function(String value, Event event);
class ItemParty extends StatefulWidget {
  final ActionPopUpItemSelectedCallback? onActionPopUpItemSelected;
  final Event event;

  const ItemParty({Key? key, required this.event, this.onActionPopUpItemSelected}) : super(key: key);

  @override
  _ItemPartyState createState() => _ItemPartyState();
}

class _ItemPartyState extends State<ItemParty> {



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.event.eventTitle,style: const TextStyle(  fontSize: 18,fontWeight: FontWeight.bold),
                    ),

                    TextSpan(
                      text:   "(${widget.event.nbParticipant} ${AppLocalizations.of(context)!.people} )",style: const TextStyle( fontSize: 16,  color: gray),
                    ),
                  ],
                ),),

              PopupMenuButton<String>(
                color: Colors.white,
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onSelected:   (String value) {
                  if (widget.onActionPopUpItemSelected != null) {
                    widget.onActionPopUpItemSelected!(value, widget.event);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                   PopupMenuItem<String>(
                    value: edit,
                    child: ListTile(
                      minLeadingWidth: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit),
                      title: Text(AppLocalizations.of(context)!.modify),
                    ),
                  ),
                   PopupMenuItem<String>(
                    value: delete,
                    child: ListTile(
                      minLeadingWidth: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline),
                      title: Text(AppLocalizations.of(context)!.delete),
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert_rounded,color: Colors.grey,),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              
                Text("${AppLocalizations.of(context)!.price}: ${widget.event.price} ${AppLocalizations.of(context)!.tunisianDinar}"),
              ],
            ),
          ),

          const SizedBox(height: 10,),

          Text(
            "${DateFormat('yyyy-MM-dd hh:mm').format( widget.event.startDate)} / ${DateFormat('yyyy-MM-dd hh:mm').format( widget.event.endDate)}",
            style: const TextStyle(
                fontSize: 16,

                color: gray),
          ),
        ],
      ),
    );
  }
}
