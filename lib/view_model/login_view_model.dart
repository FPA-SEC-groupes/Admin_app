import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/user.dart';
import '../request/login_request.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginViewModel {
  final Dio dio = Dio();
  final url = '$baseUrl/api/auth/signin';
  final SecureStorage secureStorage = SecureStorage();
  Future<User?> login(BuildContext context, LoginRequest loginRequest) async {
    try {
      Response response = await dio.post(
        url,
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        print(response.data);

        await secureStorage.writeData(authentifiedUserId, user.id.toString());
        await secureStorage.writeData(email, user.email.toString());
        await secureStorage.writeData(roleKey, user.role![0].toString());

        List<Cookie> cookies = response.headers.map['set-cookie']!
            .map((s) => Cookie.fromSetCookieValue(s))
            .toList();
        for (Cookie cookie in cookies) {
          if (cookie.name == 'helloWay') {
            await secureStorage.writeData("jwtCookie", cookie.toString());
          }
        }

        return user;
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.incorrectUsernameOrPassword),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ));
      } else if (error.response?.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.accountNotActivated),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred"),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ));
    }

    // Return null or some default user in case of errors
    return null;
  }

}






