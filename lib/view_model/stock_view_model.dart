import 'package:flutter/material.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/primary_material.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class StockViewModel {
  final SecureStorage secureStorage = SecureStorage();
  final DioInterceptor dioInterceptor;
  StockViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);

  Future<PrimaryMaterial> addPrimaryMaterialToSpace(
      PrimaryMaterial primaryMaterial) async {
    final spaceId = await secureStorage.readData(spaceIdKey);
    try {
      final response = await dioInterceptor.dio.post(
        '$baseUrl/api/primary-materials/space/$spaceId',
        data: primaryMaterial.toJson(),
      );

      if (response.statusCode == 201) {
        // PrimaryMaterial was successfully created
        final PrimaryMaterial createdPrimaryMaterial =
            PrimaryMaterial.fromJson(response.data);

        return createdPrimaryMaterial;
      } else {
        throw Exception(
            "Failed to add primary material with error: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Error: $error");
    }
  }

  Future<List<PrimaryMaterial>> getPrimaryMaterialsByIdSpace() async {
    try {
      final spaceId = await secureStorage.readData(spaceIdKey);
      final response = await dioInterceptor.dio
          .get('$baseUrl/api/primary-materials/space/$spaceId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<PrimaryMaterial> stock =
            parsedJson.map((json) => PrimaryMaterial.fromJson(json)).toList();
        return stock;
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }

  Future<void> removePrimaryMaterialFromSpace( int primaryMaterialId,) async {
    try {
      final spaceId = await secureStorage.readData(spaceIdKey);
      final response = await dioInterceptor.dio.delete(
        '$baseUrl/api/primary-materials/space/$spaceId/$primaryMaterialId',
      );

      if (response.statusCode == 204) {
        // PrimaryMaterial was successfully removed from space
        print('PrimaryMaterial removed from space.');
      } else {
        // Handle other response status codes if needed
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors that occur during the request
      print('Error: $error');
    }
  }

  Future<PrimaryMaterial> updatePrimaryMaterialInSpace(int primaryMaterialId, PrimaryMaterial updatedPrimaryMaterial) async {
    try {
      final spaceId = await secureStorage.readData(spaceIdKey);
      final response = await dioInterceptor.dio.put(
        '$baseUrl/api/primary-materials/space/$spaceId/$primaryMaterialId',
        data: updatedPrimaryMaterial.toJson(), // Convert the updatedPrimaryMaterial to JSON
      );

      if (response.statusCode == 200) {
        // If the request is successful, return the updated primary material as an object
        return PrimaryMaterial.fromJson(response.data);
      } else {
        // If the request is not successful, handle the error based on your requirement
        throw Exception('Failed to update primary material: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that may occur during the request
      throw Exception('Failed to update primary material: $e');
    }
  }
}
