import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/space.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../utils/const.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/space_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditSpaceImages extends StatefulWidget {
  final String spaceTitle;
  const EditSpaceImages({super.key, required this.spaceTitle});

  @override
  State<EditSpaceImages> createState() => _EditSpaceImagesState();
}

class _EditSpaceImagesState extends State<EditSpaceImages> {
  late SpaceViewModel _spaceViewModel;
  final SecureStorage secureStorage = SecureStorage();
  List<Asset> _images = [];
  List<Map<String, dynamic>> _imageDataList = [];
  Space? _space;



  @override
  void initState() {

    _spaceViewModel=SpaceViewModel(context);
    fetchSpaceById();
    super.initState();
  }

  Future<Space> fetchSpaceById() async {
    _imageDataList = [];
    _space = await _spaceViewModel.getSpaceById();

    for (var image in _space!.images!) {
      var imageMap = {
        'id': image.id,
        'data': base64.decode(image.data),
      };

      setState(() {
        _imageDataList.add(imageMap);
      });

    }



    return _space!;
  }


  Future<void> _pickImages() async {
    List<Asset> resultList = [];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
        selectedAssets: _images,
      );


      final spaceId = await secureStorage.readData(spaceIdKey);
      await _spaceViewModel.uploadImages(resultList,int.parse(spaceId!)).then((_) async {


        await fetchSpaceById();


      }).catchError((error) {

      });
      // Retrieve the image data for each selected asset
    } on Exception catch (e) {
      // Handle exception
    }

    setState(() {
      _images = resultList;
    });
  }

  void handleImageRemoval(int index) {
    if (index >= 0 && index < _imageDataList.length) {
      _imageDataList.removeAt(index);
      _images.removeAt(
          _imageDataList.length - (_imageDataList.length - _images.length) - 1);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return WillPopScope(
        onWillPop: () async {
          await fetchSpaceById();
          Navigator.pop(context,_space!.images!);

          return false;
    },child:Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, // Use your desired icon here
            color: Colors.white, // Customize the icon color
          ),
          onPressed: () async {
            await fetchSpaceById();
            Navigator.pop(context,_space!.images!);
          },
        ),
        title: Text( widget.spaceTitle),
      ),
      body:networkStatus == NetworkStatus.Online
          ? Padding(
        padding: const EdgeInsets.all(5),
        child: GridView.count(
          crossAxisCount: 3,
          children: List.generate(_imageDataList.length + 1, (index) {
            if (index == 0) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: DottedBorder(
                  color: gray,
                  dashPattern: [8, 4],
                  strokeWidth: 2,
                  strokeCap: StrokeCap.round,
                  borderType: BorderType.RRect,
                  radius: Radius.circular(5),
                  child: Container(
                    height: 300,
                    width: 300,
                    child: IconButton(
                      icon: Icon(
                        Icons.upload_rounded,
                        color: gray,
                      ),
                      onPressed: _pickImages,
                    ),
                  ),
                ),
              ));
            }
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.memory(
                          _imageDataList[index - 1]['data']!,
                        ),
                      )),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: InkWell(
                    onTap: () {
                        _spaceViewModel.deleteImage(_imageDataList[index - 1]['id']);
                        _imageDataList.removeAt(index-1);
                        setState(() {

                        });

                    },
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: gray),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        )
      ):Center(
    child: Padding(
    padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.network_check,
            size: 150,
            color: gray,
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noInternet,
            style: const TextStyle(fontSize: 22, color: gray),
            textAlign: TextAlign.center,
          ),
          Text(
            AppLocalizations.of(context)!.checkYourInternet,
            style: const TextStyle(fontSize: 22, color: gray),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10,),
          MaterialButton(
            color: orange,
            height: 40,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed:(){
              setState(() {

              });
            },


            child: Text(
              AppLocalizations.of(context)!.retry,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),

          )
        ],
      ),
    ),
    ),
    ));
  }
}
