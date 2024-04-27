import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/user.dart';
import 'package:hello_way/utils/const.dart';

import '../interceptors/dio_interceptor.dart';

class ModertorsViewModel {
  final DioInterceptor dioInterceptor;
  ModertorsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);

  Future<List<User>?> getModerators() async {
    try {
      final response =
      await dioInterceptor.dio.get('$baseUrl/api/users/get/moderators');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<User> waiters =
        parsedJson.map((json) => User.fromJson(json)).toList();
        return waiters;
      } else {
        throw Exception('Failed to load moderator: ${response.statusCode}');
      }
    } on DioError catch (error) {
  if (error.response?.statusCode == 400) {

  return null;

  } else {
  print(error.response?.statusCode);
  throw Exception(error);
  }
  } catch (error) {
  throw Exception(error);
  }
  }


  Future<String> addModerator(BuildContext context, User user) async {
    const url = '$baseUrl/api/auth/signup';
    final Dio dio = Dio();
      final response = await dio.post(
        url,
        data: user.toJson(),
      );

      final signupResponse = response.data['message'];

      if (response.statusCode == 200) {

        return signupResponse;

      } else {
        throw Exception("Failed to sign up");
      }

  }
  Future<void> deleteModerator(int id) async {
    try {
      final response = await dioInterceptor.dio.delete(
        "$baseUrl/api/users/delete/$id",
        options: Options(responseType: ResponseType.plain),
      );

      // Check the response status code and handle accordingly
      if (response.statusCode == 200) {
        // Successful deletion
        print("User with ID $id deleted successfully.");
      } else {
        // Error occurred
        print("Failed to delete user with ID $id. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Error occurred
      print("Error occurred while deleting user with ID $id: $e");
    }
  }

  Future<User> activateAccount(User user) async {
    try {
      // Send the PUT request with the updated zone object as the request body
      final response = await dioInterceptor.dio.put(
        '$baseUrl/api/users/update',
        data: user.toJson(),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        print(response.data);
        final User category = User.fromJson(response.data);
        return category;
      } else {
        // Handle other status codes (if needed)
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } on DioError catch (error) {

        throw Exception(error.response!.data);

    } catch (error) {
      throw Exception(error);
    }
  }
}