import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../interceptors/dio_interceptor.dart';
import '../models/user.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class WaitersViewModel {
  final DioInterceptor dioInterceptor;
  WaitersViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();
  Future<dynamic> addWaiter(BuildContext context,int moderatorId,int spaceId, User user) async {
    final url = '$baseUrl/api/spaces/moderatorUserId/$moderatorId/$spaceId/servers';

      final response = await  dioInterceptor.dio.post(
        url,
        data: user.toJson(),
      );



      if (response.statusCode == 200) {
        final message = response.data;
        return message;

      } else {
        throw Exception("Failed to sign up");
      }


  }



  Future<void> deleteWaiter(int id) async {
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


  Future<List<User>> getWaitersBySpaceId() async {
    final spaceId = await secureStorage.readData(spaceIdKey);
    try {
      final response =
      await dioInterceptor.dio.get('$baseUrl/api/spaces/servers/$spaceId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<User> waiters =
        parsedJson.map((json) => User.fromJson(json)).toList();
        print(parsedJson);
        return waiters;
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }



  Future<List<User>> getWaitersByZoneId(int zoneId) async {

    try {
      final response =
      await dioInterceptor.dio.get('$baseUrl/api/zones/servers/$zoneId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<User> waiters =
        parsedJson.map((json) => User.fromJson(json)).toList();
        return waiters;
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }







  Future<void> setServerInZone(
      String moderatorUserId,
      String spaceId,
      String serverId,
      String zoneId,
      ) async {
    try {
      String url = "$baseUrl/api/spaces/moderatorUserId/$moderatorUserId/$spaceId/servers/$serverId/zones/$zoneId";

      Response response = await dioInterceptor.dio.post(url);

      if (response.statusCode == 200) {
        print("Server successfully assigned to the zone.");
      } else {
        print("Failed to assign server to the zone.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }






  Future<double> getServerSumCommandsPerDay(int serverId, String localDate) async {
    const String url = "$baseUrl/api/commands/sumPerDay"; // Replace with your server URL

    try {
      Response response = await dioInterceptor.dio.get(
        url,
        queryParameters: {
          'serverId': serverId,
          'localDate': localDate,
        },
      );

      if (response.statusCode == 200) {
        return response.data as double;
      } else {
        throw Exception('Failed to load data'); // Handle error response as needed
      }
    } catch (e) {
      throw Exception('Network error: $e'); // Handle Dio errors
    }
  }

  Future<double> getServerSumCommandsPerMonth(int serverId, String yearMonth) async {
    const String url = "$baseUrl/api/commands/sumPerMonth"; // Replace with your server URL

    try {
      Response response = await dioInterceptor.dio.get(
        url,
        queryParameters: {
          'serverId': serverId,
          'yearMonth': yearMonth,
        },
      );

      if (response.statusCode == 200) {
        return response.data as double;
      } else {
        throw Exception('Failed to load data'); // Handle error response as needed
      }
    } catch (e) {
      throw Exception('Network error: $e'); // Handle Dio errors
    }
  }



  Future<int> getServerCommandsCountPerDay(
      int serverId,
      String localDate,
      ) async {
    try {
      final response = await dioInterceptor.dio.get(
        '$baseUrl/api/commands/countPerDay',
        queryParameters: {
          'serverId': serverId,
          'localDate': localDate,
        },
      );

      if (response.statusCode == 200) {
        return response.data as int;
      } else {
        // Handle error if needed
        throw Exception('Failed to get server commands count per day');
      }
    } catch (e) {
      // Handle error if needed
      throw Exception('Failed to get server commands count per day: $e');
    }
}




  Future<Uint8List>  fetchPdf(int spaceId) async {
    try {
      final response = await dioInterceptor.dio.get<Uint8List>("$baseUrl/api/generate-pdf/space/$spaceId",
          options: Options(responseType: ResponseType.bytes));

      if (response.statusCode == 200) {
        final data=response.data;
        print("pdf"+data!.toString());
        return data;
      } else {
        throw Exception("Failed to create qrcode.");
      }

    } catch (error) {
      print('Error: $error');
      throw Exception("Failed to create qrcode.");
    }
  }

  Future<String> removeServerFromZone( int serverId ,int zoneId) async {
    try {
      final response = await dioInterceptor.dio.delete(
        '$baseUrl/api/zones/server/$serverId/zone/$zoneId',

      );

      if (response.statusCode == 200) {
        return "Server removed successfully";
      } else {
        return "Error: ${response.data}";
      }
    } catch (error) {
      return "Error: $error";
    }
  }

}