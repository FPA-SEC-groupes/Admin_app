import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_way/models/user.dart';
import 'package:hello_way/view_model/modertors_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../res/app_colors.dart';
import '../utils/const.dart';

class ItemModerator extends StatefulWidget {
  final User user;
  final VoidCallback onDelete;
  bool? activateUser;
  ItemModerator(
      {Key? key, required this.user, required this.onDelete, this.activateUser})
      : super(key: key);

  @override
  State<ItemModerator> createState() => _ItemModeratorState();
}

class _ItemModeratorState extends State<ItemModerator> {

  late final ModertorsViewModel _modertorsViewModel ;
  late bool isActivated;

  @override
  void initState() {
    _modertorsViewModel = ModertorsViewModel(context);
    isActivated=widget.user.activated!;
    super.initState();
  }


  Future<void> actionPopUpItemSelected(String value) async {
    String message;
    if (value == delete) {
      widget.onDelete();
    } else if (value == add) {
    } else if (value == showMore) {
    } else {
      message = 'Not implemented';
      print(message);
    }
  }

  launchCaller(String phoneNumber) async {
    final PermissionStatus status = await Permission.phone.request();
    if (status == PermissionStatus.granted) {
      // Remplacez par votre numéro de téléphone
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
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Stack(
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
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:  [
                          Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          Text(
                            AppLocalizations.of(context)!.call,
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          //Image.network("http://10.0.2.2:9090/img/${game.url}", width: 200, height: 94),

          SizedBox(
            width: 10,
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
              Text(
                "${widget.user.name} ${widget.user.lastname}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.user.email,
              ),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.activateTheAccount),
                  Switch(
                    activeColor: orange,
                    value: isActivated,
                    onChanged: (bool value) async {
                      widget.user.activated=value;
                      print(widget.user.toString());

                      _modertorsViewModel.activateAccount(widget.user).then((user) async {
                        setState(() {
                          isActivated=user.activated!;

                        });
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ))
        ],
      ),
    );
  }
}
