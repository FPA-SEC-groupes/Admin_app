import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_way/models/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../res/app_colors.dart';
import '../utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../view/manager/waiter_details.dart';
class ItemWaiter extends StatefulWidget {
  final User user;
  final VoidCallback onDelete;
  const ItemWaiter({Key? key, required this.user, required this.onDelete}) : super(key: key);

  @override
  State<ItemWaiter> createState() => _ItemWaiterState();
}

class _ItemWaiterState extends State<ItemWaiter> {
  Future<void> actionPopUpItemSelected(String value) async {
    String message;
    if (value == delete) {
      widget.onDelete();
    } else if (value == add) {
    } else if (value == showMore) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaiterDetails(
            waiter: widget.user,
          ),
        ),
      );
    } else {
      message = 'Not implemented';
      print(message);
    }
  }

  launchCaller(String phoneNumber) async {
    final PermissionStatus status = await Permission.phone.request();
    if (status == PermissionStatus.granted) {
      final uri = Uri.parse(phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Impossible de lancer l\'appel : $phoneNumber';
      }
    } else {
      throw 'La permission d\'accéder au téléphone n\'a pas été accordée';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      height: 170,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: gray.withOpacity(0.5),
                backgroundImage: widget.user.image == null
                    ? null
                    : MemoryImage(base64.decode(widget.user.image!)),
                child: widget.user.image == null
                    ? const Icon(
                  Icons.person_rounded,
                  size: 100,
                  color: Colors.white,
                )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: GestureDetector(
                  onTap: () {
                    launchCaller("tel:${widget.user.phone!}");
                  },
                  child: Container(
                    height: 30,
                    constraints: const BoxConstraints(
                      minWidth: 25,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        Text(
                          AppLocalizations.of(context)!.call,
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),


          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  offset: const Offset(0, 40),
                  padding: EdgeInsets.zero,
                  onSelected: (String value) => actionPopUpItemSelected(
                    value,
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                     PopupMenuItem<String>(
                      value: showMore,
                      child: ListTile(
                        minLeadingWidth: 10,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.read_more_rounded),
                        title: Text(AppLocalizations.of(context)!.showMore),
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
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  "${widget.user.name!} ${widget.user.lastname!}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text(
                  widget.user.email,
                ),
              ),
              const SizedBox(height: 10,)
            ],
          ))
        ],
      ),
    );
  }
}
