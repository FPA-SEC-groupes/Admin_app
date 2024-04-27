import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import '../interceptors/dio_interceptor.dart';
import '../models/space.dart';
import '../utils/const.dart';
import 'package:http_parser/http_parser.dart';

import '../utils/secure_storage.dart';

class SpaceViewModel {
  final SecureStorage secureStorage = SecureStorage();
  final DioInterceptor dioInterceptor;
  SpaceViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  Future<Space> addSpaceByIdManager(
      Space space, int moderatorId, int categoryId) async {
    try {
      // Define the API endpoint URL
      final url =
          '$baseUrl/api/spaces/add/idModerator/$moderatorId/idSpaceCategory/$categoryId';
      // Send the request to the API endpoint using the dioInterceptor
      final response = await dioInterceptor.dio.post(
        url,
        data: space.toJson(),
      );
      // Handle the response from the API
      if (response.statusCode == 200) {
        // Category was added successfully, display a success message to the user
        print(Space.fromJson(response.data));
        final space = Space.fromJson(response.data);
        await secureStorage.writeData(spaceIdKey, space.id.toString());

        return space;
      } else {
        throw Exception("Failed to add space.");
      }
    } on DioError catch (e) {

      throw Exception("Failed to add space.");
    }
  }

  Future<Space?> getSpaceByIdModerator(int moderatorId) async {
    try {
      final response = await dioInterceptor.dio
          .get('$baseUrl/api/spaces/idModerator/$moderatorId');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data.isNotEmpty) {
          print(data);
          final space = Space.fromJson(data);

          await secureStorage.writeData(spaceIdKey, space.id.toString());

          return space;
        } else {
          return null;
        }
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to load space: $e');
    }
    return null;
  }

  Future<Space> getSpaceById() async {
    try {
      final spaceId = await secureStorage.readData(spaceIdKey);

      final response =
          await dioInterceptor.dio.get('$baseUrl/api/spaces/id/$spaceId');

      if (response.statusCode == 200) {
        final data = response.data;
        final space = Space.fromJson(data);
        await secureStorage.writeData(spaceIdKey, space.id.toString());

        return space;
      } else {
        // Handle non-200 status code
        throw Exception('Failed to load space: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to load space: $e');
    }
  }

  Future<void> getSpaceByIdWaiter(int waiterId) async {
    try {
      final response =
          await dioInterceptor.dio.get('$baseUrl/api/spaces/server/$waiterId');

      if (response.statusCode == 200) {
        final data = response.data;
        print(response.data);
        final space = Space.fromJson(data);
        await secureStorage.writeData(spaceIdKey, space.id.toString());
      } else {
        // Request failed
        print('Request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors that occurred during the request
      print('Error: $error');
    }
  }

 Future<Space> updateSpace(Space space) async {
    const url = '$baseUrl/api/spaces/update';

      final response = await dioInterceptor.dio.put(
        url,
        data: space.toJson(),
      );

      if (response.statusCode == 200) {

        final data = response.data;
        final space = Space.fromJson(data);
        return space;
      } else {
        // Handle non-200 status code
        throw Exception('Failed to load space: ${response.statusCode}');
      }


  }

  Future<void> uploadImages(List<Asset> images, int spaceId) async {

    final uri = '$baseUrl/api/spaces/$spaceId/images';
    for (int i = 0; i < images.length; i++) {
      final asset = images[i];
      final byteData = await asset.getByteData();
      final file = byteData.buffer.asUint8List();

      // Compress the image before uploading
      final compressedFile = await FlutterImageCompress.compressWithList(
        file,
        minHeight: 1080,
        minWidth: 720,
        quality: 75,
      );

      // Convert the compressed file to a multipart file
      MultipartFile multipartFile = MultipartFile.fromBytes(
        compressedFile,
        filename: asset.name,
        contentType: MediaType('image', asset.name!.split('.').last),
      );

      final formData = FormData.fromMap({
        'file': multipartFile,
      });
      var response = await dioInterceptor.dio.post(
        uri,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200) {

      } else {

        throw Exception("Failed to add category.");
      }
    }
  }


  Future<void> deleteImage(String idImage) async {

    final spaceId = await secureStorage.readData(spaceIdKey);
    try {
      final response = await dioInterceptor.dio.delete('$baseUrl/api/spaces/$idImage/images/$spaceId');

      if (response.statusCode == 200) {
        print('Image deleted successfully');
      } else if (response.statusCode == 404) {
        print('Image not found');
      } else {
        print('Failed to delete image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }
}
