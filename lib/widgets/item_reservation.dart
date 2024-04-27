

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reservation.dart';
import '../res/app_colors.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ItemReservation extends StatefulWidget {
  final Reservation reservation;

  const ItemReservation({
    super.key,
    required this.reservation,
  });

  @override
  State<ItemReservation> createState() => _ItemReservationState();
}

class _ItemReservationState extends State<ItemReservation> {

  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');



  @override
  Widget build(BuildContext context) {

    return Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "${AppLocalizations.of(context)!.reservation}  N°${widget.reservation.idReservation} ",
                style: const TextStyle(
                    fontSize: 18,fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5,),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: widget.reservation.status ==
                      "NOT_YET"
                      ? Colors.orangeAccent
                      : widget.reservation.status ==
                      "CONFIRMED"
                      ? Colors.green
                      : Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.reservation.status == "NOT_YET"
                      ? AppLocalizations.of(context)!.pendingStatus
                      : widget.reservation.status ==
                      "REFUSED"
                      ? AppLocalizations.of(context)!.refusedStatus
                      : widget.reservation.status ==
                      "CONFIRMED"
                      ? AppLocalizations.of(context)!.confirmedStatus
                      : AppLocalizations.of(context)!.canceledStatus,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),


          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                  text:widget.reservation.eventTitle.substring(0,1).toUpperCase()+widget.reservation.eventTitle.substring(1),style: const TextStyle(  fontSize: 16),
                ),

                TextSpan(
                  text:    " (${widget.reservation.numberOfGuests} ${AppLocalizations.of(context)!.people})",style: const TextStyle( fontSize: 16,  color: gray),
                ),
              ],
            ),),

          const SizedBox(height: 10,),
          Text(formatter.format(widget.reservation.startDate),style: const TextStyle(  color: gray))
        ]));
  }
}
