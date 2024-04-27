import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/utils/const.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../utils/secure_storage.dart';
import '../view_model/modertors_view_model.dart';
import '../view_model/waiters_view_model.dart';
import '../widgets/button.dart';
import '../widgets/input_form.dart';
import '../widgets/input_form_password.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/snack_bar.dart';

class AddUser extends StatefulWidget {
  bool? isModerator;
  AddUser({Key? key, this.isModerator}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  late final WaitersViewModel _waitersViewModel;
  late final ModertorsViewModel _modertorsViewModel;
  final SecureStorage secureStorage = SecureStorage();
  final GlobalKey<FormState> _addUserFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _addUserScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final _usernameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    _waitersViewModel = WaitersViewModel(context);
    _modertorsViewModel = ModertorsViewModel(context);
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    } else if (value != _passwordController.text.trim()) {
      return AppLocalizations.of(context)!.passwordsDoNotMatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return ScaffoldMessenger(
        key: _addUserScaffoldKey,
        child: Scaffold(
          appBar: Toolbar(title: widget.isModerator != null
              ? "Ajouter un gérant"
              : AppLocalizations.of(context)!.addWaiter),
          body:networkStatus == NetworkStatus.Online
              ? Center(
              child: Form(
            key: _addUserFormKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const SizedBox(
                            height: 15,
                          ),
                          InputForm(
                            hint: AppLocalizations.of(context)!.username,
                            controller: _usernameController,
                            prefixIcon:
                                const Icon(Icons.person_outline_rounded),
                            contentPadding: const EdgeInsets.all(10),
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: AppLocalizations.of(context)!
                                      .inputRequiredError),
                            ]),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: InputForm(
                                  hint: AppLocalizations.of(context)!.lastname,
                                  controller: _firstnameController,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  contentPadding: const EdgeInsets.all(10),
                                  validator: MultiValidator([
                                    RequiredValidator(
                                        errorText: AppLocalizations.of(context)!
                                            .inputRequiredError),
                                  ]),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InputForm(
                                  hint: AppLocalizations.of(context)!.firstname,
                                  controller: _lastnameController,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  contentPadding: const EdgeInsets.all(10),
                                  validator: MultiValidator([
                                    RequiredValidator(
                                        errorText: AppLocalizations.of(context)!
                                            .inputRequiredError),
                                  ]),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputForm(
                            hint: AppLocalizations.of(context)!.email,
                            controller: _emailController,
                            prefixIcon: const Icon(Icons.email_outlined),
                            contentPadding: const EdgeInsets.all(10),
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: AppLocalizations.of(context)!
                                      .inputRequiredError),
                              EmailValidator(
                                  errorText: AppLocalizations.of(context)!
                                      .invalidEmail)
                            ]),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          InputForm(
                            keyboardType: TextInputType.number,
                            hint: AppLocalizations.of(context)!.phoneNumber,
                            controller: _phoneNumberController,
                            prefixIcon: const Icon(Icons.phone),
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
                            height: 15,
                          ),
                          InputFormPassword(
                            controller: _passwordController,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            hint: AppLocalizations.of(context)!.password,
                            onChanged: (value) {
                              setState(
                                  () {}); // Trigger a rebuild when the password field value changes
                            },
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: AppLocalizations.of(context)!
                                      .inputRequiredError),
                              MinLengthValidator(
                                8,
                                errorText: AppLocalizations.of(context)!
                                    .passwordLengthError,
                              ),
                            ]),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          InputFormPassword(
                              controller: _confirmPasswordController,
                              enabled:
                                  _passwordController.text.trim().isNotEmpty,
                              prefixIcon: const Icon(Icons.lock_open_rounded),
                              hint: AppLocalizations.of(context)!
                                  .passwordConfirmation,
                              validator: _validatePasswordConfirmation),
                          const SizedBox(
                            height: 20,
                          ),
                          Button(
                            text: AppLocalizations.of(context)!.add,
                            onPressed: () async {
                              if (_addUserFormKey.currentState!.validate()) {
                                _addUserFormKey.currentState!.save();
                                if (widget.isModerator == null) {
                                  final moderatorId = await secureStorage
                                      .readData(authentifiedUserId);
                                  final spaceId =
                                      await secureStorage.readData(spaceIdKey);
                                  final waiter = User(
                                    username: _usernameController.text.toString().trim(),
                                    name: _firstnameController.text
                                        .toString()
                                        .trim(),
                                    lastname: _lastnameController.text
                                        .toString()
                                        .trim(),
                                    phone: _phoneNumberController.text
                                        .toString()
                                        .trim(),
                                    email:
                                        _emailController.text.toString().trim(),
                                    password: _passwordController.text
                                        .toString()
                                        .trim(),
                                  );

                                  _waitersViewModel.addWaiter(
                                          context,
                                          int.parse(moderatorId!),
                                          int.parse(spaceId!),
                                          waiter)
                                      .then((message) {
                                    Navigator.pop(context,message);
                                  }).catchError((error) {
                                    if (error is DioError) {
                                      if (error.response?.statusCode == 400) {
                                        final message =
                                            error.response?.data['message'];
                                        if (message ==
                                            "Error: Username is already taken!") {
                                          _addUserScaffoldKey.currentState
                                              ?.showSnackBar( SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!.usernameTakenError),
                                            duration: const Duration(seconds: 3),
                                            backgroundColor: Colors.red,
                                          ));
                                        } else if (message ==
                                            "Error: Email is already in use!") {
                                          _addUserScaffoldKey.currentState
                                              ?.showSnackBar( SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!.emailInUseError),
                                            duration: const Duration(seconds: 3),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      }
                                    }
                                  });
                                } else {
                                  try {
                                    final moderator = User(
                                      username: _usernameController.text
                                          .toString()
                                          .trim(),
                                      name: _firstnameController.text
                                          .toString()
                                          .trim(),
                                      lastname: _lastnameController.text
                                          .toString()
                                          .trim(),
                                      phone: _phoneNumberController.text
                                          .toString()
                                          .trim(),
                                      email: _emailController.text
                                          .toString()
                                          .trim(),
                                      password: _passwordController.text
                                          .toString()
                                          .trim(),
                                      role: ["provider"],
                                    );

                                    _modertorsViewModel
                                        .addModerator(context, moderator)
                                        .then((message) {
                                      var snackBar = customSnackBar(
                                        context,
                                        AppLocalizations.of(context)!.managerAddedSuccessfully,
                                        Colors.green,
                                      );
                                      _addUserScaffoldKey.currentState
                                          ?.showSnackBar(snackBar);
                                      print(message);
                                      Navigator.pop(context,message);
                                    }).catchError((error) {
                                      if (error is DioError) {
                                        if (error.response?.statusCode == 400) {
                                          final message =
                                              error.response?.data['message'];
                                          if (message ==
                                              "Error: Username is already taken!") {
                                            _addUserScaffoldKey.currentState
                                                ?.showSnackBar( SnackBar(
                                              content: Text(
                                                  AppLocalizations.of(context)!.usernameTakenError),
                                              duration: const Duration(seconds: 3),
                                              backgroundColor: Colors.red,
                                            ));
                                          } else if (message ==
                                              "Error: Email is already in use!") {
                                            _addUserScaffoldKey.currentState
                                                ?.showSnackBar( SnackBar(
                                              content: Text(
                                                  AppLocalizations.of(context)!.emailInUseError),
                                              duration: Duration(seconds: 3),
                                              backgroundColor: Colors.red,
                                            ));
                                          }
                                        }
                                      }
                                    });
                                  } catch (error) {
                                    // Handle other exceptions
                                    print("Unexpected Error: $error");
                                  }
                                }
                              }
                            },
                          )
                        ]),
                  ),
                ],
              ),
            ),
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
