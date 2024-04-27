
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hello_way/models/event.dart';

import '../interceptors/dio_interceptor.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';
import 'package:http_parser/http_parser.dart';
class EventsViewModel {
  final DioInterceptor dioInterceptor;
  EventsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();


  Future<void> createPromotionForSpace(Event event,int productId) async {
    final spaceId = await secureStorage.readData(spaceIdKey);
    String url = '$baseUrl/api/events/promotion/space/$spaceId/$productId'; // Replace with the Promotion object you want to send

    try {
      Response response = await dioInterceptor.dio.post(
       url,
        data: event.toJson(), // Assuming Promotion class has toJson() method
      );

      if (response.statusCode == 200) {
        // Request successful
        var eventObject = response.data;
        // Handle the event object or perform any desired actions
        print('Event Object: $eventObject');
      } else {
        // Request failed
        print('Request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      // Error during the request
      print('Error: $error');
    }
  }



  Future<Event> createPartyForSpace(Event event) async {
    final spaceId = await secureStorage.readData(spaceIdKey);
    String url = '$baseUrl/api/events/party/space/$spaceId';

    try {
      Response response = await dioInterceptor.dio.post(
        url,
        data: event.toJson(), // Assuming Promotion class has toJson() method
      );

      if (response.statusCode == 200) {

        return  Event.fromJson(response.data);
      } else {
        // Request failed
        print('Request failed with status code: ${response.statusCode}');
        throw Exception("Request failed with status code: ${response.statusCode}");
      }
    } catch (error) {
      // Error during the request
      print('Error: $error');
      throw Exception("Error: $error'");
    }
  }


  Future<List<Event>> getEventsBySpaceId() async {
    final spaceId = await secureStorage.readData(spaceIdKey);
    String url = '$baseUrl/api/events/spaces/$spaceId'; // Replace with the Promotion object you want to send

    try {
      Response response = await dioInterceptor.dio.get(url);

      if (response.statusCode == 200) {
        // Request successful
        List<Event> events = (response.data as List<dynamic>).map((e) => Event.fromJson(e)).toList();
        // Handle the list of events or perform any desired actions
        return events;
      } else {
        // Request failed
        print('Request failed with status code: ${response.statusCode}');
        throw Exception("Request failed with status code: ${response.statusCode}");
      }
    } catch (error) {
      // Error during the request
      print('Error: $error');
      throw Exception('Error: $error');
    }
  }



  Future<void> uploadImage(File image, int eventId) async {
    final uri = '$baseUrl/api/events/$eventId/images';

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
    final formData = FormData.fromMap({'file': multipartFile});
    var response = await dioInterceptor.dio.post(
      uri,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.statusCode == 200) {
      print('Image added successfully!');
    } else {
      print('Failed to add image. Error code: ${response.statusCode}');
      throw Exception("Failed to add image.");
    }
    print('success');
  }



  Future<Event> fetchEventById(int eventId) async {
  // Replace with your actual API base URL
    final String url = '$baseUrl/api/events/$eventId'; // Replace with the correct API endpoint

    try {
      final response = await dioInterceptor.dio.get(url, options: Options(
      ));

      if (response.statusCode == 200) {
        // Successful response, parse the data and return the Event object
        return Event.fromJson(response.data);
      }else{
    throw Exception('Error fetching event: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors, e.g., connection issues, timeouts, etc.

      throw Exception('Error fetching event: $error');
    }
  }

  Future<Event?> updatePromotion(Event updatedEvent) async {
    const String url = '$baseUrl/api/events/update/promotion'; // Replace with the correct API endpoint

    try {
      final response = await dioInterceptor.dio.put(url, data: updatedEvent.toJson(),
      );

      if (response.statusCode == 200) {
        // Successful response, parse the data and return the updated Event object
        return Event.fromJson(response.data);
      } else {
        throw Exception('Error updating event: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error updating event: $error');
    }
  }

  Future<Event?> updateParty(Event updatedEvent) async {
    const String url = '$baseUrl/api/events/update'; // Replace with the correct API endpoint

    try {
      final response = await dioInterceptor.dio.put(url, data: updatedEvent.toJson(),
      );

      if (response.statusCode == 200) {
        // Successful response, parse the data and return the updated Event object
        return Event.fromJson(response.data);
      } else {
        throw Exception('Error updating event: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error updating event: $error');
    }
  }

}