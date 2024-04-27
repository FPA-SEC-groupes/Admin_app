import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/view_model/products_view_model.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../../models/space.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/gallery_permission_view_model.dart';
import '../../view_model/space_view_model.dart';
import '../../widgets/button.dart';
import '../../widgets/input_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'edit_space_images.dart';

class UpdateSpace extends StatefulWidget {
   Space space;

   UpdateSpace({Key? key, required this.space, }) : super(key: key);

  @override
  State<UpdateSpace> createState() => _UpdateSpaceState();
}

class _UpdateSpaceState extends State<UpdateSpace> {
  final SecureStorage secureStorage = SecureStorage();
  late PageController _pageController;
  int _currentPage = 0;
  List<Widget> _pages = [];
  Timer? _timer;

  late SpaceViewModel _spaceViewModel;

  final GlobalKey<FormState> _updateSpaceFormKey = GlobalKey<FormState>();
  late final TextEditingController _titleSpaceController,
      _surfaceController,
      _descriptionController,
      _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _spaceViewModel = SpaceViewModel(context);
    _titleSpaceController = TextEditingController();
    _phoneNumberController= TextEditingController();
    _surfaceController = TextEditingController();
    _descriptionController = TextEditingController();

    _titleSpaceController.text=widget.space.title;
    _phoneNumberController.text=widget.space.phoneNumber.toString();
    _surfaceController.text=widget.space.surfaceEnM2.toString();
    _descriptionController.text=widget.space.description;
    fetchImages();

  }

  @override
  void dispose() {
    _titleSpaceController.dispose();
    _surfaceController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _phoneNumberController.dispose();
    stopTimer();
    super.dispose();
  }


  Future<void> fetchImages() async {

    setState(() {
      _pages = widget.space.images!.isEmpty
          ? [
        const FittedBox(
          child: Icon(Icons.image_outlined, color: gray),
        )
      ]
          : List.generate(
        widget.space.images!.length,
            (index) => SizedBox(
          height: 50,
          child: ClipRRect(
            child: FittedBox(
              fit: BoxFit.fill,
              child: Image.memory(
                base64.decode(widget.space.images![index].data),
              ),
            ),
          ),
        ),
      );
    });


    startTimer();

  }

  void startTimer() {
    if (_pages.length <= 1) {
      return; // Exit the method if there's only one page
    }
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (_pageController.hasClients){
      if (_currentPage < _pages.length - 1) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      } else {

        _pageController.jumpToPage(
          0,
        );}
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: Toolbar(
          title: widget.space.title,
        ),
        body: networkStatus == NetworkStatus.Online
            ?Form(
          key: _updateSpaceFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [

                Stack(
                  children: [
                    Container(
                      height: screenHeight / 3,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: _pages,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                        List<Widget>.generate(_pages.length, (int index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 10,
                            width: (index == _currentPage) ? 30 : 10,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: (index == _currentPage)
                                  ? orange
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditSpaceImages(
                                spaceTitle: widget.space.title,
                              ),
                            ),
                          );

                          if (result != null) {


                            setState(() {
                              widget.space.images =result;
                              fetchImages();
                            });
                            print( widget.space.images);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                        ),
                        child: const Icon(
                          Icons.edit,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(children: [
                    const SizedBox(
                      height: 20,
                    ),
                    InputForm(
                      hint: AppLocalizations.of(context)!.title,
                      controller: _titleSpaceController,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppLocalizations.of(context)!
                                .inputRequiredError),
                      ]),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputForm(
                      hint: AppLocalizations.of(context)!.phoneNumber,
                      controller: _phoneNumberController,
                      contentPadding: const EdgeInsets.all(10),
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppLocalizations.of(context)!
                                .inputRequiredError),
                        LengthRangeValidator(
                            min: 8,
                            max: 12,
                            errorText: AppLocalizations.of(context)!
                                .phoneLengthError),
                        PatternValidator(r'(^(?:\+216)?[0-9]{8}$)',
                            errorText: AppLocalizations.of(context)!
                                .phonePatternError),
                      ]),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputForm(
                      hint: AppLocalizations.of(context)!.price,
                      keyboardType: TextInputType.number,
                      controller: _surfaceController,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppLocalizations.of(context)!
                                .inputRequiredError),
                      ]),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputForm(
                      maxLines: 5,
                      hint: AppLocalizations.of(context)!.description,
                      controller: _descriptionController,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppLocalizations.of(context)!
                                .inputRequiredError),
                      ]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Button(
                      text: AppLocalizations.of(context)!.modify,
                      onPressed: () async {
                        if (_updateSpaceFormKey.currentState!.validate()) {
                          _updateSpaceFormKey.currentState!.save();
                          widget.space.title=_titleSpaceController.text.toString();
                          widget.space.phoneNumber=int.parse(_phoneNumberController.text.toString());
                          widget.space.surfaceEnM2=double.parse(_surfaceController.text.toString());
                          widget.space.description=_descriptionController.text.toString();

                          _spaceViewModel.updateSpace(widget.space).then((space) async {

                            Navigator.pop(context,space);


                          }).catchError((error) {

                          });


                        }
                      },
                    )
                  ]),
                ),
              ],
            ),
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
        ),);
  }
}
