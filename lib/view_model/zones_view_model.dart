import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/zone.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class ZonesViewModel {
  final SecureStorage secureStorage = SecureStorage();
  final DioInterceptor dioInterceptor;
  ZonesViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  Future<void> addZoneByIdSpace(Zone zone) async {

      final spaceId = await secureStorage.readData(spaceIdKey);
      final url = '$baseUrl/api/zones/add/id_space/$spaceId';
      // Send the request to the API endpoint using the dioInterceptor
      final response = await dioInterceptor.dio.post(
        url,
        data: zone.toJson(),
      );
      // Handle the response from the API
      if (response.statusCode == 200) {
        // Category was added successfully, display a success message to the user
        print('Product added successfully!');
      } else {
        // Category addition failed, display an error message to the user
        print('Failed to add product. Error code: ${response.statusCode}');
        throw Exception("Failed to add product.");
      }

  }

  Future<List<Zone>> getZonesByIdSpace() async {
    try {
      final spaceId = await secureStorage.readData(spaceIdKey);
      final response = await dioInterceptor.dio
          .get('$baseUrl/api/zones/all/id_space/$spaceId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<Zone> zones =
            parsedJson.map((json) => Zone.fromJson(json)).toList();
        return zones;
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }

  Future<void> deleteZone(int zoneId) async {
    try {
      // Send the DELETE request
      final response =
          await dioInterceptor.dio.delete('$baseUrl/api/zones/delete/$zoneId');

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Zone deleted successfully
        print('Zone deleted successfully.');
      } else {
        // Handle other status codes (if needed)
        print('Failed to delete zone. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle Dio errors (network, timeouts, etc.)
      print('Error deleting zone: $e');
    }
  }

  Future<Zone> updateZone(Zone zone) async {
    // Send the PUT request with the updated zone object as the request body
    final response = await dioInterceptor.dio.put(
      '$baseUrl/api/zones/update/${zone.id!}',
      data: zone.toJson(),
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final Zone zone = Zone.fromJson(response.data);;
      // Zone updated successfully
      return zone;
      print('Zone updated successfully.');
    } else {
      // Handle other status codes (if needed)
      throw Exception('Failed to load zones: ${response.statusCode}');
    }
  }




}
