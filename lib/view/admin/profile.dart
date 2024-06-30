import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/user.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/services/network_service.dart';
import 'package:hello_way/utils/const.dart';
import 'package:hello_way/view_model/gallery_permission_view_model.dart';
import 'package:hello_way/view_model/modertors_view_model.dart';
import 'package:hello_way/view_model/profile_view_model.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:hello_way/widgets/dialog.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ModertorsDetails extends StatefulWidget {
  final User modertors;
  const ModertorsDetails({super.key, required this.modertors});
  // const Profile({Key? key}) : super(key: key);

  @override
  State<ModertorsDetails> createState() => _ModertorsDetailsState();
}

class _ModertorsDetailsState extends State<ModertorsDetails> {
  final GalleryViewModel _galleryViewModel = GalleryViewModel();
  late final ModertorsViewModel _modertorsViewModel;

  late final ProfileViewModel _profileViewModel;
  final TextEditingController _textEditingController = TextEditingController();
  DateTime currentDate = DateTime.now();

  User? _user;
  String? errorText;
  @override
  void initState() {
    getUserById();
    _profileViewModel = ProfileViewModel(context);
    _modertorsViewModel = ModertorsViewModel(context);
    getManagerSumCommandsPerMonth(widget.modertors.id);
    super.initState();
  }
  Future<double> getManagerSumCommandsPerMonth(serverId) async {
    String formattedDate = DateFormat('yyyy-MM').format(currentDate);
    double sum = await  _modertorsViewModel.getManagerSumCommandsPerMonth(
        widget.modertors.id!, formattedDate);
    sum = sum -(sum/ (1 + widget.modertors.percentage! / 100));
    return sum;
  }
  Future<User> getUserById() async {
    return widget.modertors;
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
                  widget.modertors!.username=_textEditingController.text.trim();
                  break;
                case 2:
                  widget.modertors!.email=_textEditingController.text.trim();
                  break;
                case 3:
                  widget.modertors!.phone=_textEditingController.text.trim();
                  break;
                default:
                // Code to execute if none of the above cases match
              }
              _profileViewModel
                  .updateUser(widget.modertors!)
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
        appBar:  Toolbar(title: AppLocalizations.of(context)!.managerDetails),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          // child:networkStatus == NetworkStatus.Online
          //     ?
          child:Padding(
              padding: const EdgeInsets.only(top: 50),
              child:
                      Column(
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
                                                      : widget.modertors.image == null
                                                          ? const Icon(
                                                              Icons
                                                                  .person_rounded,
                                                              color: Colors.white,
                                                              size: 100,
                                                            )
                                                          :Image.network('$baseUrl$userUrl${widget.modertors.image}')
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
                          title: Text(widget.modertors.username,
                              style: const TextStyle(fontSize: 16)),
                          onTap: () async {

                            _textEditingController.text=widget.modertors!.username;
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
                          title: Text(widget.modertors.email,
                              style: const TextStyle(fontSize: 16)),
                          onTap: () {

                           _textEditingController.text= widget.modertors!.email;
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
                          title: Text(widget.modertors.phone.toString(),
                              style: const TextStyle(fontSize: 16)),
                          onTap: () {
                         _textEditingController.text=widget.modertors!.phone.toString();
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
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.percent),
                          visualDensity: const VisualDensity(vertical: 0.0),
                          dense: true,
                          title: Text(widget.modertors.percentage.toString(),
                              style: const TextStyle(fontSize: 16)),
                          onTap: () async {

                            _textEditingController.text=widget.modertors!.percentage.toString();
                            updateUser(1,_validateUsername,AppLocalizations.of(context)!.percentage,"Edit",);
                          },
                          trailing: const Icon(
                            Icons.navigate_next_rounded,
                          ),
                        ),
                        SizedBox(height: 20,),
                          Padding(padding: EdgeInsetsDirectional.all(10),
                            child:Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: orange, // Or any color you want
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text("${AppLocalizations.of(context)!.on} ${DateFormat('dd-MM-yyyy').format(currentDate)}",style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(
                                    child: FutureBuilder<double>(
                                      future: getManagerSumCommandsPerMonth(widget.modertors.id),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text('Error: ${snapshot.error}'),
                                          );
                                        } else {
                                          double sum = snapshot.data!;
                                          sum = double.parse(sum.toStringAsFixed(2));
                                          return Column(

                                            children: [
                                              SvgPicture.asset('assets/images/coin.svg',
                                                  height: 60, width: 60, color: Colors.white),
                                              Text('$sum ${AppLocalizations.of(context)!.tunisianDinar}',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  // Expanded(
                                  //   child:FutureBuilder<int>(
                                  //     future: getServerCommandsCountPerDay(widget.modertors.id),
                                  //     builder: (context, snapshot) {
                                  //       if (snapshot.connectionState ==
                                  //           ConnectionState.waiting) {
                                  //         return const Center(
                                  //           child: CircularProgressIndicator(),
                                  //         );
                                  //       } else if (snapshot.hasError) {
                                  //         return Center(
                                  //           child: Text('Error: ${snapshot.error}'),
                                  //         );
                                  //       } else {
                                  //         int nbOrders = snapshot.data!;
                                  //         return Column(
                                  //           children: [
                                  //             const Icon(
                                  //               Icons.file_copy,
                                  //               size: 50,
                                  //               color: Colors.white,
                                  //             ),
                                  //             Text('$nbOrders ${AppLocalizations.of(context)!.orders}',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                                  //           ],
                                  //         );
                                  //       }
                                  //     },
                                  //   ),)
                                ],
                              ),
                            ],
                          ),
                        ),
                          )
                      ],
                    ),
          ),
        )
    );
  }
}
