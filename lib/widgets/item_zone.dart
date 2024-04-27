import 'package:flutter/material.dart';
import 'package:hello_way/view/manager/list_tables.dart';
import '../models/zone.dart';
import '../utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemZone extends StatefulWidget {
  final Zone zone;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onAdd;
  const ItemZone({
    super.key,
    required this.zone, required this.onDelete, required this.onUpdate, required this.onAdd,
  });

  @override
  State<ItemZone> createState() => _ItemZoneState();
}

class _ItemZoneState extends State<ItemZone> {

  Future<void> actionPopUpItemSelected(String value, Zone zone) async {
    if (value == delete) {
      widget.onDelete();
    }else if (value == edit) {
      widget.onUpdate();
    } else if (value == add) {
     widget.onAdd();
    } else if (value == showMore) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListTables(
            zone: zone,
          ),
        ),
      );
    } else {
    }
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
              Text(
                widget.zone.title,
                style: const TextStyle(
                    fontSize: 18,

                    color: Colors.black),
              ),
              PopupMenuButton<String>(
                color: Colors.white,
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onSelected: (String value) =>
                    actionPopUpItemSelected(value, widget.zone),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

                   PopupMenuItem<String>(
                    value: showMore,
                    child: ListTile(
                      minLeadingWidth: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.read_more_rounded),
                      title: Text(AppLocalizations.of(context)!.viewAllTables),
                    ),
                  ),
                   PopupMenuItem<String>(
                    value: add,
                    child: ListTile(
                      minLeadingWidth: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.add),
                      title: Text(AppLocalizations.of(context)!.addTable),
                    ),
                  ),
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


        ]));
  }
}
