import 'package:flutter/material.dart';
import 'package:hello_way/utils/const.dart';

import '../interceptors/dio_interceptor.dart';

class ForgetPasswordViewModel{
  final DioInterceptor dioInterceptor;
  ForgetPasswordViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);

  Future<String> resetPassword(String email) async {
    try {
      final resetPasswordRequest = {
        "email": email,
      };

      final response = await dioInterceptor.dio.post(
        '$baseUrl/api/auth/reset-password/email',
        data: resetPasswordRequest,
      );

      if (response.statusCode == 200) {
        print(response.data);
       return response.data['message'] as String;;
      } else {
        // Handle other status codes and error cases
        print('Password reset failed: ${response.data}');
        // Handle non-200 status codes
        throw Exception('Password reset failed: ${response.data}');
      }
    } catch (e) {
      // Handle any errors that occur during the API call
      throw Exception('Password reset failed: $e');
    }
  }
}