import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import '../interceptors/dio_interceptor.dart';
import '../models/user.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class ProfileViewModel {
  final SecureStorage secureStorage = SecureStorage();

  final DioInterceptor dioInterceptor;
  ProfileViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);


  Future<User> fetchUserById() async {
    String? id = await secureStorage.readData(authentifiedUserId);

    final url = '$baseUrl/api/users/id/$id';

    try {
      final response = await dioInterceptor.dio.get(url);
      if (response.statusCode == 200) {
        final userData = response.data;
        print(userData);
        return User.fromJson(userData);
      } else {
        // Handle non-200 status codes
        throw Exception(
            'Failed to fetch user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle Dio errors or network errors
      throw Exception('Failed to fetch user: $error');
    }
  }

  Future<void> uploadProfileImage(File image) async {
    String? userId = await secureStorage.readData(authentifiedUserId);
    final url = '$baseUrl/api/users/$userId/add-image';

    String fileName = image.path.split("/").last;

    Uint8List bytes = await image.readAsBytes();

    // Compress the image before uploading
    final compressedFile = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 1920,
      minWidth: 1080,
      quality: 90,
    );

    // Convert the compressed file to a multipart file
    MultipartFile multipartFile = MultipartFile.fromBytes(compressedFile,
        filename: fileName,
        contentType: MediaType('image', fileName.split('.').last));
    final formData = FormData.fromMap({'image': multipartFile});
    var response = await dioInterceptor.dio.post(
      url,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.statusCode == 200) {
      print('Image added successfully!');
    } else {
      // Category addition failed, display an error message to the user
      print('Failed to add image. Error code: ${response.statusCode}');
      throw Exception("Failed to add image.");
    }
    print('success');
  }

  Future<void> logout() async {
    final url = '$baseUrl/api/auth/signout';
    try {
      final response = await dioInterceptor.dio.post(
        url,
      );

      if (response.statusCode == 200) {
        await secureStorage.deleteAll();
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle Dio errors
      print('Error: $error');
    }
  }

  Future<User> updateUser(User user) async {

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
        throw Exception('Failed to update user: ${response.statusCode}');
      }

  }
}
