import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_way/models/space.dart';
import 'package:hello_way/utils/const.dart';
import 'package:hello_way/view_model/space_view_model.dart';
import 'package:im_stepper/stepper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../utils/routes.dart';
import '../../utils/secure_storage.dart';
import '../../widgets/input_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddSpace extends StatefulWidget {
  const AddSpace({Key? key}) : super(key: key);

  @override
  State<AddSpace> createState() => _AddSpaceState();
}

class _AddSpaceState extends State<AddSpace> {
  int activeStep = 0; // Initial step set to 5.
  int upperBound = 2; // upperBound MUST BE total number of icons minus 1.
  final SecureStorage secureStorage = SecureStorage();
  late SpaceViewModel _spaceViewModel;
  // Step 1
  String? _selectedCategorie;

  final GlobalKey<FormState> _addSpaceFormKey = GlobalKey<FormState>();
  late final TextEditingController _spaceNameController,
      _surfaceController,
      _phoneNumberController,
      _descriptionController;

  // Step 2


  List<Asset> _images = [];

  Future<void> _pickImages() async {
    List<Asset> resultList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
        selectedAssets: _images,
      );

    } on Exception catch (e) {
      // Handle exception
    }
    setState(() {
      _images = resultList;
    });
  }
  //Step3

  late GoogleMapController mapController;

  LatLng? _currentPosition;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  @override
  void initState() {
    super.initState();


    _spaceViewModel = SpaceViewModel(context);
    _spaceNameController = TextEditingController();
    _surfaceController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      _isLoading = false;
      _markers = {
        Marker(
          markerId: MarkerId("marker_1"),
          position: _currentPosition!,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _currentPosition = newPosition;
            });
          },
        ),
      };
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }



  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: orange,
          title: Text( AppLocalizations.of(context)!.addSpace),
        ),
        body:networkStatus == NetworkStatus.Online
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              IconStepper(
                activeStepColor: orange,
                lineColor: orange,
                stepColor: gray,
                enableNextPreviousButtons: false,
                icons: const [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                  ),
                    Icon(Icons.image_outlined,color: Colors.white),
                  Icon(Icons.location_on_outlined, color: Colors.white),
                ],

                // activeStep property set to activeStep variable defined above.
                activeStep: activeStep,

                // This ensures step-tapping updates the activeStep.
                onStepReached: (index) {
                  setState(() {
                    activeStep = index;
                  });
                },
              ),
              Expanded(child: headerText()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  activeStep == 0 ? const SizedBox() : previousButton(),
                  activeStep == 2
                      ? nextButton( AppLocalizations.of(context)!.validate)
                      : nextButton( AppLocalizations.of(context)!.next),
                ],
              ),
            ],
          ),
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
      ),
    );
  }

  /// Returns the next button.
  Widget nextButton(String text) {
    return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            children: [
              Text(
                text,
                style: const TextStyle(
                    color: orange, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.navigate_next_rounded,
                color: orange,
              )
            ],
          ),
        ),
        onTap: () async {
          var category;

          final userId = await secureStorage.readData(authentifiedUserId);

          if (activeStep == 0) {
    if (_addSpaceFormKey.currentState!.validate()) {
    _addSpaceFormKey.currentState!.save();
    if(_selectedCategorie=="Restaurant"){
      category=1;
    }
    else if(_selectedCategorie=="Bar"){
      category=3;
    }
    else if(_selectedCategorie=="Café"){
      category=2;
    }

    print(category);
    setState(() {
      activeStep++;
    });


    }
    }
          else if(activeStep==1){
            await getLocation();
            setState(() {
              activeStep++;
            });


          }else if(activeStep==2){

            if(_selectedCategorie=="Restaurant"){
              category=1;
            }
              else if(_selectedCategorie=="Bar"){
              category=2;
            }
              else if(_selectedCategorie=="Café"){
              category=3;
            }

              print(category);
            Space space= Space(title: _spaceNameController.text.trim(),
                latitude: _currentPosition!.latitude,
                longitude: _currentPosition!.longitude,
                description:_descriptionController.text.trim().toString(),
                phoneNumber: int.parse(_phoneNumberController.text.trim()),
                surfaceEnM2: double.parse(_surfaceController.text),numberOfRatings: 0);
            await _spaceViewModel.addSpaceByIdManager(space,int.parse(userId!),category).then((space) async {

               await _spaceViewModel.uploadImages(_images,space.id!).then((_) async {
                 Navigator.pushNamed(context,managerBottomNavigationRoute);

               }).catchError((error) {

               });
            }).catchError((error) {
              print(error);
            });

          }
        });
  }

  /// Returns the previous button.
  Widget previousButton() {
    return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            children:  [
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: gray,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                AppLocalizations.of(context)!.back,
                style: TextStyle(
                    color: gray, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        onTap: ()  {
          if (activeStep > 0) {
            setState(() {
              activeStep--;
            });
          }

        });
  }

  Widget headerText() {
    final listCategories = initListCategories(context);
    switch (activeStep) {
      case 0:
        return Form(
          key: _addSpaceFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(children: [
                    const SizedBox(
                      height: 20,
                    ),
                    InputForm(
                      hint:  AppLocalizations.of(context)!.title,
                      controller: _spaceNameController,
                      contentPadding: const EdgeInsets.all(10),
                      validator: MultiValidator([
                        RequiredValidator(errorText:  AppLocalizations.of(context)!.inputRequiredError),
                      ]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField2(
                      value: _selectedCategorie,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: orange,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: orange,
                            )),

                        // Added this
                      ),

                      hint:  Text(
                       AppLocalizations.of(context)!.category,

                      ),
                      items:
                          listCategories.map((item) => DropdownMenuItem<String>(


                                value: item.values.first,
                                child: Text(
                                  item.keys.first,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              )).toList(),
                      validator: (value) {
                        if (value == null) {
                          return  AppLocalizations.of(context)!.inputRequiredError;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        //Do something when changing the item if you want.
                        _selectedCategorie = value.toString();
                      },
                      onSaved: (value) {
                        _selectedCategorie = value.toString();
                      },
                      buttonStyleData: const ButtonStyleData(
                        height: 50,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 30,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputForm(
                      hint:  AppLocalizations.of(context)!.area,
                      keyboardType: TextInputType.number,
                      controller: _surfaceController,
                      contentPadding: const EdgeInsets.all(10),
                      validator: MultiValidator([
                        RequiredValidator(errorText:  AppLocalizations.of(context)!.inputRequiredError),
                      ]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputForm(
                      hint: AppLocalizations.of(context)!.phoneNumber,
                      // controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
                      contentPadding: const EdgeInsets.all(10),
                      controller: _phoneNumberController,
                      validator: MultiValidator([
                        RequiredValidator(errorText:  AppLocalizations.of(context)!.phoneRequiredError),
                        LengthRangeValidator(
                            min: 8,
                            max: 12,
                            errorText:
                            AppLocalizations.of(context)!.phoneLengthError),
                        PatternValidator(r'(^(?:\+216)?[0-9]{8}$)',
                            errorText:
                            AppLocalizations.of(context)!.phonePatternError),
                      ]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputForm(
                      maxLines: 5,
                      hint:  AppLocalizations.of(context)!.description,
                      controller: _descriptionController,
                      validator: MultiValidator([
                        RequiredValidator(errorText:  AppLocalizations.of(context)!.inputRequiredError),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        );

      case 1:
        return  Padding(
          padding: const EdgeInsets.all(15),
          child: GridView.count(
            crossAxisCount: 3,
            children: List.generate(_images.length + 1, (index) {
              if (index == 0) {
                return Center(
                    child: Padding(
                      padding: const EdgeInsets.all( 5.0),
                      child: DottedBorder(
                        color: gray,
                        dashPattern: [8, 4],
                        strokeWidth: 2,
                        strokeCap: StrokeCap.round,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(5),
                        child: SizedBox(
                          height: 300,
                          width: 300,
                          child: IconButton(
                            icon: const Icon(Icons.upload_rounded,color: gray,),
                            onPressed: _pickImages,),
                        ),
                      ),
                    )
                );

              }
              return Padding(
                padding: const EdgeInsets.all( 5.0),
                child: AssetThumb(
                  asset: _images[index - 1],
                  width: 300,
                  height: 300,
                ),
              );
            }),
          ),
        );
      case 2:
        return _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 16.0,
                ),
                // enable user location

                // padding: EdgeInsets.only(bottom: 75.0),
                zoomControlsEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                onTap: (newPosition) {
                  setState(() {
                    _markers = {
                      Marker(
                        markerId: MarkerId("marker_1"),
                        position: newPosition,
                        draggable: true,
                        onDragEnd: (newPosition) {
                          setState(() {
                            _currentPosition = newPosition;
                          });
                        },
                      ),
                    };
                    _currentPosition = newPosition;
                  });
                },
              );
      default:
        return Container();
    }
  }
}
