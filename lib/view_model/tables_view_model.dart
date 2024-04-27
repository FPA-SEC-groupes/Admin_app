import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/board.dart';

import '../interceptors/dio_interceptor.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class TablesViewModel {
  final DioInterceptor dioInterceptor;
  TablesViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();
  Future<Board> addTable(Board board, int zoneId) async {
      // Define the API endpoint URL
      final url = '$baseUrl/api/boards/add/id_zone/$zoneId';
      // Send the request to the API endpoint using the dioInterceptor
      final response = await dioInterceptor.dio.post(url, data: board.toJson());
      // Handle the response from the API
      if (response.statusCode == 200) {
        return Board.fromJson(response.data);
      } else {
        print('Failed to add board. Error code: ${response.statusCode}');
        throw Exception("Failed to add board.");
      }

  }

  Future<List<Board>> getBoardByZoneId(int zoneId) async {
    try {
      final response =
          await dioInterceptor.dio.get('$baseUrl/api/boards/id_zone/$zoneId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<Board> boards =
            parsedJson.map((json) => Board.fromJson(json)).toList();
        return boards;
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }


  Future<List<Board>> getTablesByDisponibilities(String date) async {
    try {
      final spaceId = await secureStorage.readData(spaceIdKey);
      // Request parameters
      final Map<String, dynamic> params = {
        'date': date,
      };

      final response =
      await dioInterceptor.dio.get('$baseUrl/api/reservations/availability/$spaceId',queryParameters: params);

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<Board> boards =
        parsedJson.map((json) => Board.fromJson(json)).toList();
        return boards;
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }

  Future<List<Board>> getTablesByReservationId(int reservationId) async {
    try {

      final response =
      await dioInterceptor.dio.get('$baseUrl/api/reservations/tables/$reservationId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<Board> boards =
        parsedJson.map((json) => Board.fromJson(json)).toList();
        return boards;
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }



  Future<Uint8List>  fetchQrCodeImage(int tableId,int zoneId) async {
    try {
      final response = await dioInterceptor.dio.get<Uint8List>('$baseUrl/api/qrcodes/$tableId/zoneId/$zoneId',
          options: Options(responseType: ResponseType.bytes));

      if (response.statusCode == 200) {
        final data=response.data;
        print(data);
        return data!;
      } else {
        throw Exception("Failed to create qrcode.");
      }

    } catch (error) {
      print('Error: $error');
      throw Exception("Failed to create qrcode.");
    }
  }



  Future<dynamic> addBasketByTableId(String tableId) async {
    try {
      final response = await dioInterceptor.dio.post(
          '$baseUrl/api/baskets/tables/$tableId/baskets',
          data:{}
      );
      if (response.statusCode == 200) {

        await secureStorage.writeData(basketIdKey,response.data['id_basket'].toString());
        return response.data;
      } else {
        throw Exception('Failed to add basket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add basket: $e');
    }
  }
  Future<void> deleteTable(int tableId) async {
    try {

      // Send the DELETE request
      final response = await dioInterceptor.dio.delete('$baseUrl/api/boards/delete/$tableId');

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


  Future<Board> updateTable(Board table) async {
    try {

      // Send the PUT request with the updated zone object as the request body
      final response = await dioInterceptor.dio.put('$baseUrl/api/boards/update',data: table.toJson(),);

      // Check if the request was successful
      if (response.statusCode == 200) {
        return Board.fromJson(response.data);
      } else {
        throw Exception("Failed to update board.");
      }
    } catch (e) {
      // Handle Dio errors (network, timeouts, etc.)
      throw Exception('Error updating zone: $e');
    }
  }
}
