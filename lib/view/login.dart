import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/request/login_request.dart';
import 'package:hello_way/utils/routes.dart';
import 'package:hello_way/view_model/ShiftViewModel.dart';
import 'package:hello_way/widgets/input_form.dart';
import 'package:provider/provider.dart';
import '../models/shift.dart';
import '../models/user.dart';
import '../services/network_service.dart';
import '../utils/const.dart';
import '../view_model/login_view_model.dart';
import '../view_model/space_view_model.dart';
import '../widgets/button.dart';
import '../widgets/input_form_password.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LoginViewModel _loginViewModel = LoginViewModel();
  late final SpaceViewModel _spaceViewModel;
  late final ShiftViewModel _shiftViewModel;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController, _passwordController;

  @override
  void initState() {
    super.initState();
    _spaceViewModel = SpaceViewModel(context);
    _shiftViewModel = ShiftViewModel(context);
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Form(
          key: _loginFormKey,
          child:  GestureDetector(
                  onTap: () {
                final FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        top: 30.0, // Increase top margin to push the content down
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain, // This will keep the aspect ratio of the image
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          InputForm(
                            hint: AppLocalizations.of(context)!.username,
                            controller: _usernameController,
                            prefixIcon: const Icon(Icons.person),
                            contentPadding: const EdgeInsets.all(10),
                            validator: MultiValidator([
                              LengthRangeValidator(
                                  min: 4,
                                  max: 20,
                                  errorText:
                                  AppLocalizations.of(context)!.inputRequiredError),
                              RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                            ]),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InputFormPassword(
                            hint: AppLocalizations.of(context)!.password,
                            controller: _passwordController,
                            prefixIcon: const Icon(Icons.lock),
                            contentPadding: const EdgeInsets.all(10),
                          ),
                          GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20, bottom: 20),
                              child: Text("${AppLocalizations.of(context)!.forgotPassword}?"),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, forgetPasswordRoute);
                            },
                          ),
                          Button(
                            text: AppLocalizations.of(context)!.login,
                            onPressed: () async {
                              if (_loginFormKey.currentState!.validate()) {
                                _loginFormKey.currentState!.save();

                                var loginRequest = LoginRequest(
                                  username: _usernameController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );

                                _loginViewModel.login(context, loginRequest).then((user) async {
                                  if (user!.role![0].toString() == roleManager) {
                                    await _spaceViewModel.getSpaceByIdModerator(user.id!).then((space) async {
                                      if (space != null) {
                                        Navigator.pushReplacementNamed(context, managerBottomNavigationRoute);
                                      } else {
                                        Navigator.pushReplacementNamed(context, addSpaceRoute);
                                      }
                                    }).catchError((error) {
                                      print("Error getting space by ID for manager: $error");
                                    });
                                  } else if(user.role![0].toString()==roleWaiter){
                                    print("fgg");
                                    await _spaceViewModel.getSpaceByIdWaiter(user.id!).then((space) async {
                                      Navigator.pushReplacementNamed(context,waiterBottomNavigationRoute);


                                      print("hhh");

                                    }).catchError((error) {

                                    });

                                  } else if (user.role![0].toString() == roleAdmin) {
                                    Navigator.pushReplacementNamed(context, listModeratorsRoute);
                                  }
                                }).catchError((error) {
                                  print("Login error: $error");
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            )
          ),
        ),
      ),
    );
  }
}
