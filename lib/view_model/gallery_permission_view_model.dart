import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class GalleryViewModel extends ChangeNotifier  {
  final picker = ImagePicker();
  File? _image;

  File? get image => _image;

  Future<bool> requestGalleryPermission(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {

      await showDialog(
        context: context,
        builder: (_context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.photosPermissionTitle),
          content: Text(AppLocalizations.of(context)!.photosPermissionContent),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.openSettingsButton),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
          ],
        )
      );
    }

    return false;
  }

  Future<void> selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }


}