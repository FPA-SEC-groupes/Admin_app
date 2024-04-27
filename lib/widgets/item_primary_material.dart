

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/primary_material.dart';
import '../res/app_colors.dart';
import '../utils/const.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ItemPrimaryMaterial extends StatefulWidget {
  final PrimaryMaterial primaryMaterial;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const ItemPrimaryMaterial({
    Key? key,
    required this.primaryMaterial,
    required this.onDelete, required this.onUpdate,
  }) : super(key: key);


  @override
  State<ItemPrimaryMaterial> createState() => _ItemPrimaryMaterialState();
}

class _ItemPrimaryMaterialState extends State<ItemPrimaryMaterial> {
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');


  Future<void> actionPopUpItemSelected(String value, PrimaryMaterial primaryMaterial) async {
    String message;
    if (value == delete) {
      widget.onDelete();
    } else if (value == edit) {

      widget.onUpdate();
    } else {
      message = 'Not implemented';
      print(message);
    }
  }


  @override
  Widget build(BuildContext context) {

    return Container(
        padding: const EdgeInsets.fromLTRB(20,10, 10, 20),
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(widget.primaryMaterial.title.substring(0,1).toUpperCase()+widget.primaryMaterial.title.substring(1),
                style: const TextStyle(
                    fontSize: 18,fontWeight: FontWeight.bold),
              ),
              PopupMenuButton<String>(
                color: Colors.white,
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onSelected: (String value) =>
                    actionPopUpItemSelected(value, widget.primaryMaterial),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                   PopupMenuItem<String>(
                    value: "edit",
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
          Text("${AppLocalizations.of(context)!.stockQuantity}: ${widget.primaryMaterial.stockQuantity} ${widget.primaryMaterial.unitOfMeasure}"),
          const SizedBox(height: 10,),
          Text("${AppLocalizations.of(context)!.price}: ${widget.primaryMaterial.price} ${AppLocalizations.of(context)!.tunisianDinar}/${widget.primaryMaterial.unitOfMeasure}"),



          const SizedBox(height: 10,),
          Text("${AppLocalizations.of(context)!.expirationDate}: ${formatter.format(widget.primaryMaterial.expirationDate)}",style: const TextStyle(  color: gray))
        ]));
  }
}
