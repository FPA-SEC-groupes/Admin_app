import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/utils/routes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


 /* @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 5), () {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => Login() ));
      Navigator.pushReplacementNamed(context, loginRoute);
    });
  }*/

  late Future<bool> sessionFetched;
  late String route;

  Future<bool> fetchSession() async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    Timer(const Duration(seconds: 3), () async {

      if(await secureStorage.containsKey( key: authentifiedUserId) && await secureStorage.containsKey( key: roleKey)) {
        var role= await secureStorage.read(key:roleKey);
        if(role==roleManager){
          final spaceId=await secureStorage.read(key: spaceIdKey,);
          if(spaceId!=null){
            Navigator.pushReplacementNamed(context, managerBottomNavigationRoute);
          }else{
            Navigator.pushReplacementNamed(context, addSpaceRoute);
          }

        }else if(role==roleWaiter){
          Navigator.pushReplacementNamed(context, waiterBottomNavigationRoute);
        }else if(role==roleAdmin){
          Navigator.pushReplacementNamed(context, listModeratorsRoute);
        }



      }
      else {
        Navigator.pushReplacementNamed(context, loginRoute);

      }
    });


    return true;
  }

  @override
  void initState() {
    sessionFetched = fetchSession();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Column(
            children:<Widget> [
        Expanded(

        flex: 9,
        child: Align(
        alignment: Alignment.center,
              child:Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,

                child:Image.asset("assets/images/logo.jpg"),

              ),)),
      Expanded(
          flex: 1,
        child: Align(
          alignment: Alignment.bottomCenter,

              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
              child:LinearPercentIndicator(
                animation: true,
                lineHeight: 15,
                animationDuration: 3000,
                percent: 1,
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: orange,

              ))))

            ],

          ),

        );
  }
}
