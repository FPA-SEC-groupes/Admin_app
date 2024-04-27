import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way/models/event.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:intl/intl.dart';
import '../utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../view/manager/add_new_promotion.dart';

typedef ActionPopUpItemSelectedCallback = Future<void> Function(String value, Event event);
class ItemPromotion extends StatefulWidget {
  final ActionPopUpItemSelectedCallback? onActionPopUpItemSelected;
  final Event event;

  const ItemPromotion({Key? key, required this.event, this.onActionPopUpItemSelected}) : super(key: key);

  @override
  _ItemPromotionState createState() => _ItemPromotionState();
}

class _ItemPromotionState extends State<ItemPromotion> {



  Future<void> actionPopUpItemSelected(String value) async {
    if (value == delete) {

    }
    else if (value == edit) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder:
                  (context) =>
                  AddNewPromotion(
                    promotionId:
                    widget.event.idEvent,
                  )
          )).then((value) {

      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10,left: 10,right: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.event.eventTitle,style: const TextStyle(  fontSize: 18,fontWeight: FontWeight.bold),),
              PopupMenuButton<String>(
                color: Colors.white,
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onSelected:  (String value) {
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
                      leading: const Icon(Icons.delete_outline),
                      title: Text(AppLocalizations.of(context)!.delete),
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert_rounded,color: Colors.grey,),
              ),
            ],
          ),





          Text("${AppLocalizations.of(context)!.reduction} ${widget.event.percentage} %"),
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
