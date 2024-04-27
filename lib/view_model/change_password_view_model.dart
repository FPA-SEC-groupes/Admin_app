

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../interceptors/dio_interceptor.dart';
import '../request/reset_password_request.dart';
import '../utils/const.dart';

class ChangePasswordViewModel{

  final DioInterceptor dioInterceptor;
  ChangePasswordViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);

  Future<void> changePassword(BuildContext context,ResetPasswordRequest resetPasswordRequest) async {
    // Define the API endpoint URL
    final url = '$baseUrl/api/auth/reset-password';

    // Define the request body, including the current and new password

    // Send the request to the API endpoint using the dioInterceptor
    final response = await dioInterceptor.dio.post(
      url,
      data: resetPasswordRequest.toJson(),
    );

    // Handle the response from the API
    if (response.statusCode == 200) {
      // Password change was successful, display a success message to the user
      print('Password changed successfully!');
    } else {
      // Password change failed, display an error message to the user
      print('Failed to change password. Error code: ${response.statusCode}');
    }
  }


}