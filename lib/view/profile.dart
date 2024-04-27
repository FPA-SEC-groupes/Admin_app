import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/view_model/profile_view_model.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/user.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../view_model/gallery_permission_view_model.dart';
import '../widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/dialog.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GalleryViewModel _galleryViewModel = GalleryViewModel();
  late final ProfileViewModel _profileViewModel;
  final TextEditingController _textEditingController = TextEditingController();
  User? _user;
  String? errorText;
  @override
  void initState() {
    getUserById();
    _profileViewModel = ProfileViewModel(context);
    super.initState();
  }

  Future<User> getUserById() async {
    User user = await _profileViewModel.fetchUserById();
    _user=user;
    return user;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    } else if (errorText != null) {
      return AppLocalizations.of(context)!.usernameTakenError;
    }
    return null;
  }

  updateUser(int value,String? Function(String?)? validator,String hint ,String title,{TextInputType? keyboardType}) async {
    await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, update) {
          return CustomDialog(
            title: title,
            validator: validator,
            controller: _textEditingController,
            hint: hint,
            keyboardType:keyboardType?? TextInputType.text,
            submit: () async {
              switch (value) {
                case 1:
                  _user!.username=_textEditingController.text.trim();
                  break;
                case 2:
                  _user!.email=_textEditingController.text.trim();
                  break;
                case 3:
                  _user!.phone=_textEditingController.text.trim();
                  break;
                default:
                // Code to execute if none of the above cases match
              }
              _profileViewModel
                  .updateUser(_user!)
                  .then((user) async {
                Navigator.of(context).pop();
                setState(() {
                  getUserById();
                });

              }).catchError((error) {
                if (error is DioError) {
                  if (error.response?.statusCode ==
                      400) {
                    // Handle 400 status code error (Bad Request)
                    update(() {
                      errorText = AppLocalizations.of(
                          context)!
                          .usernameTakenError;
                      print(errorText);
                    });
                  }
                } else {
                  // Handle other errors
                  print("Error: $error");
                }
              });
            },
            cancel: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
        appBar:  Toolbar(title: AppLocalizations.of(context)!.profile),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:networkStatus == NetworkStatus.Online
              ? Padding(
              padding: const EdgeInsets.only(top: 50),
              child: FutureBuilder<User>(
                future: getUserById(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return Column(
                      children: [
                        Center(
                            child: MultiProvider(
                                providers: [
                              ChangeNotifierProvider(
                                  create: (_) => _galleryViewModel),
                            ],
                                child: Consumer<GalleryViewModel>(
                                    builder: (context, galleryViewModel, _) =>
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 70.0,
                                              backgroundColor:
                                                  Colors.grey.withOpacity(0.5),
                                              child: ClipOval(
                                                child: Container(
                                                  width: 140.0,
                                                  height: 140.0,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: galleryViewModel.image !=
                                                          null
                                                      ? Image.file(
                                                          galleryViewModel.image!,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : user.image == null
                                                          ? const Icon(
                                                              Icons
                                                                  .person_rounded,
                                                              color: Colors.white,
                                                              size: 100,
                                                            )
                                                          : Image.memory(
                                                              base64.decode(
                                                                  user.image!),
                                                              fit: BoxFit.cover,
                                                            ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: orange,
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 4)),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    bool isGranted =
                                                        await galleryViewModel
                                                            .requestGalleryPermission(
                                                                context);
                                                    if (isGranted) {
                                                      await galleryViewModel
                                                          .selectImage();
                                                      print(_galleryViewModel
                                                          .image!);
                                                      _profileViewModel
                                                          .uploadProfileImage(
                                                              _galleryViewModel
                                                                  .image!)
                                                          .then((_) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                 SnackBar(
                                                          content: Text(
                                                              AppLocalizations.of(context)!.profilePictureModifiedSuccessfully),
                                                          duration: const Duration(
                                                              seconds: 3),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ));
                                                      }).catchError((error) {
                                                        print(error);
                                                      });
                                                    } else {
                                                      // Do something when permission is not granted
                                                    }
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        )))),
                        const SizedBox(
                          height: 50,
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_outline_outlined),
                          visualDensity: const VisualDensity(vertical: 0.0),
                          dense: true,
                          title: Text(user.username,
                              style: const TextStyle(fontSize: 16)),
                          onTap: () async {

                            _textEditingController.text=_user!.username;
                            updateUser(1,_validateUsername,AppLocalizations.of(context)!.username,"Edit",);
                          },
                          trailing: const Icon(
                            Icons.navigate_next_rounded,
                          ),
                        ), // add child widgets here
                        const Divider(),

                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          visualDensity: const VisualDensity(vertical: 0.0),
                          dense: true,
                          title: Text(user.email,
                              style: const TextStyle(fontSize: 16)),
                          onTap: () {

                           _textEditingController.text= _user!.email;
                            updateUser(2, MultiValidator([
                              RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                              EmailValidator(errorText: AppLocalizations.of(context)!.invalidEmail)
                            ]),AppLocalizations.of(context)!.email,"Edit",);
                          },
                          trailing: const Icon(
                            Icons.navigate_next_rounded,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          visualDensity: const VisualDensity(vertical: 0.0),
                          dense: true,
                          title: Text(user.phone.toString(),
                              style: const TextStyle(fontSize: 16)),
                          onTap: () {
                         _textEditingController.text=_user!.phone.toString();
                            updateUser(3,  MultiValidator([
                              RequiredValidator(
                                  errorText: AppLocalizations.of(context)!.phoneRequiredError),
                              LengthRangeValidator(
                                  min: 8,
                                  max: 12,
                                  errorText:
                                  AppLocalizations.of(context)!.phoneLengthError),
                              PatternValidator(r'(^(?:\+216)?[0-9]{8}$)',
                                  errorText:
                                  AppLocalizations.of(context)!.phonePatternError),
                            ])

                              ,AppLocalizations.of(context)!.phoneNumber,"Edit",);
                          },
                          trailing: const Icon(
                            Icons.navigate_next_rounded,
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Column(
                      children: [
                        Center(
                            child: Stack(
                          children: [
                            Shimmer.fromColors(
                              baseColor: gray.withOpacity(0.5),
                              highlightColor: Colors.white,
                              child: const CircleAvatar(
                                radius: 70.0,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffE5E4E2),
                                  border:
                                      Border.all(color: Colors.white, width: 4),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        )),
                        const SizedBox(
                          height: 50,
                        ),
                        Shimmer.fromColors(
                          baseColor: gray.withOpacity(0.5),
                          highlightColor: Colors.white,
                          child: Container(
                            color: gray,
                            height: 50,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Shimmer.fromColors(
                          baseColor: gray.withOpacity(0.5),
                          highlightColor: Colors.white,
                          child: Container(
                            color: gray,
                            height: 50,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Shimmer.fromColors(
                          baseColor: gray.withOpacity(0.5),
                          highlightColor: Colors.white,
                          child: Container(
                            color: gray,
                            height: 50,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    );
                  }
                },
              )):Center(
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
