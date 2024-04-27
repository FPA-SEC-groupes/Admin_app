import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/utils/routes.dart';
import '../res/app_colors.dart';
import '../utils/secure_storage.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DioInterceptor {

    final Dio dio = Dio();
    final SecureStorage secureStorage = SecureStorage();// Replace with your session ID key
    final BuildContext context;

    DioInterceptor(this.context) {
      dio.interceptors.add(InterceptorsWrapper(
          onRequest: (options, handler) async {
            final jwtCookie = await secureStorage.readData('jwtCookie');

            final cookie = jwtCookie; // Replace with your cookie
            options.headers['cookie'] = cookie;

            return handler.next(options);
          },

          onError: (DioError error, handler) async {
            if (error.response?.statusCode == 401) {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.sessionExpired),
                      content: Text(AppLocalizations.of(context)!.sessionExpiredDialogContent),
                      actions: <Widget>[

                        TextButton(
                          onPressed: (){
                            secureStorage.deleteAll();
                            Navigator.of(context).pop();
                          },
                          child:  Text(
                            AppLocalizations.of(context)!.alertDialogOkText,
                            style: TextStyle(color: orange),
                          ),
                        ),
                      ],
                    );
                  }).then((_) async {
                Navigator.pushNamedAndRemoveUntil(context,loginRoute, (route) => false);
                secureStorage.deleteAll();
              }).catchError((error) {

              });

              return;
            }

            return handler.next(error);
          }


      ));
    }

}