import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hello_way/models/board.dart';
import 'package:hello_way/models/zone.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../res/app_colors.dart';
import '../utils/const.dart';
import '../view_model/tables_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ItemTable extends StatefulWidget {
  final Board table;
  final Zone zone;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const ItemTable({
    Key? key,
    required this.table,
    required this.zone, required this.onDelete, required this.onUpdate,
  }) : super(key: key);

  @override
  _ItemTableState createState() => _ItemTableState();
}

class _ItemTableState extends State<ItemTable> {
  late final TablesViewModel _tablesViewModel;
  Uint8List? image;


  bool showAdditionalElements = false;



  Future<void> actionPopUpItemSelected(String value, Zone zone) async {
    String message;
    if (value == delete) {
      widget.onDelete();
    }else if (value == edit) {
      widget.onUpdate();
    }
    else if (value == downloadQrCode) {
      _downloadImage(image!);
    } else {
      message = 'Not implemented';
      print(message);
    }
  }
  Future<void> _fetchQrCode() async {
    // fetch the list of categories using
    Uint8List data = await _tablesViewModel.fetchQrCodeImage(
        widget.table.id!, widget.zone.id!);
    setState(() {
      image = data;
    });
  }

  @override
  void initState() {
    _tablesViewModel = TablesViewModel(context);
    super.initState();
    _fetchQrCode();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Hello 1");
        _fetchQrCode();

        showAdditionalElements = !showAdditionalElements;
      },
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: showAdditionalElements?const EdgeInsets.only( top:20.0,right: 20,left: 20):const EdgeInsets.all( 20.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text:  "${AppLocalizations.of(context)!.table} ${widget.table.numTable}",style: const TextStyle(  fontSize: 18),
                          ),

                          TextSpan(
                            text:    " (${widget.table.placeNumber} ${AppLocalizations.of(context)!.places})",style: const TextStyle( fontSize: 16,  color: gray),
                          ),
                        ],
                      ),),

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
                          value: edit,
                          child: ListTile(
                            minLeadingWidth: 10,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit),
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
                         PopupMenuItem<String>(
                          value: downloadQrCode,
                          child: ListTile(
                            minLeadingWidth: 10,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.download),
                            title: Text(AppLocalizations.of(context)!.downloadQrCode),
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert_rounded,color: Colors.grey,),
                    )
                  ]),
            ),
            Visibility(
              visible: showAdditionalElements,
              child: Column(
                children: [
                  Stack(
                    children: [
                      image != null
                          ? SizedBox(
                              height: MediaQuery.of(context).size.width,
                              width: MediaQuery.of(context).size.width,
                              child: Image.memory(image!),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.width,
                            ),

                    ],
                  ),
                 MaterialButton(
                     color: orange,
                     padding: EdgeInsets.all(5),

                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children:  [
                         const Icon(
                           Icons.download,
                           color: Colors.white,
                           size: 40,
                         ),
                         Text(AppLocalizations.of(context)!.download,style: const TextStyle(fontSize: 20,color: Colors.white),)
                       ],

                     ),
                     onPressed: () async {
                       _downloadImage(image!);
                     }, )
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }




  Future<void> _downloadImage( Uint8List imageBytes) async {
    try {
      // Get the external storage directory
      Directory? appDocDir = await getExternalStorageDirectory();
      if (appDocDir != null) {
        // Create a unique file name for the image
        String fileName = 'Table ${widget.table.numTable}.png';

        // Get the full path to save the file
        String imagePath = '${appDocDir.path}/$fileName';
        File file = File(imagePath);
        await file.writeAsBytes(imageBytes);
        await ImageGallerySaver.saveImage(imageBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.qrCodeDownloadSuccess),backgroundColor: Colors.green),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.downloadError),backgroundColor: Colors.red),
      );
    }
  }
}



