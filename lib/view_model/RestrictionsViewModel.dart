import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_way/utils/const.dart';

import '../interceptors/dio_interceptor.dart';
import '../../models/Restriction.dart';
import '../utils/secure_storage.dart';

class RestrictionsViewModel {
  final SecureStorage secureStorage = SecureStorage();

  final DioInterceptor dioInterceptor;
  RestrictionsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);

  Future<List<Restriction>> getAllRestrictions() async {
    try {
      var response = await dioInterceptor.dio.get('$baseUrl/api/restrictions');

      if (response.statusCode == 200) {
        var restrictionList = (response.data as List)
            .map((json) => Restriction.fromJson(json))
            .toList();
        return restrictionList;
      } else {
        throw Exception('Failed to load restrictions: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception('Failed to load restrictions: $error');
    }
  }

  Future<Restriction> getRestrictionById(int id) async {
    try {
      var response = await dioInterceptor.dio.get('$baseUrl/api/restrictions/$id');

      if (response.statusCode == 200) {
        return Restriction.fromJson(response.data);
      } else {
        throw Exception('Failed to load restriction: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception('Failed to load restriction: $error');
    }
  }

  Future<Restriction> createRestriction(Restriction restriction) async {
    try {
      print(restriction.toJson());
      var response = await dioInterceptor.dio.post(
        '$baseUrl/api/restrictions',
        data: restriction.toJson(),
      );

      if (response.statusCode == 201) {
        return Restriction.fromJson(response.data);
      } else {
        throw Exception('Failed to create restriction: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception('Failed to create restriction: $error');
    }
  }
  Future<Restriction> getRestrictionByReservationId(int reservationId) async {
    try {
      print(reservationId);
      var response = await dioInterceptor.dio.get('$baseUrl/api/restrictions/restrictions/$reservationId');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['body'] is Map<String, dynamic>) {
          // Handle the case where the API returns a Restrictions object
          try {
            return Restriction.fromJson(response.data['body']); // Extract the 'body' part of the response
          } catch (e) {
            // Handle JSON parsing error, return default restriction with empty description
            print('Error parsing restriction JSON: $e');
            return Restriction(description: "No restriction");
          }
        } else if (response.data['body'] is String) {
          // Handle the case where the API returns a string message
          print("No restriction found");
          return Restriction(description: "No restriction");  // Use the message directly as the restriction description
        } else {
          // Handle unexpected response types
          return Restriction(description: "Unexpected response from server");
        }
      } else {
        // Handle unexpected status codes
        print('Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to load restriction: ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      // Handle Dio-specific errors
      print('Exception fetching restriction: $dioError');
      throw Exception('Failed to load restriction due to Dio error: $dioError');
    } catch (error) {
      // Catch any other errors
      print('Exception fetching restriction: $error');
      throw Exception('Failed to load restriction due to error: $error');
    }
  }




  Future<Restriction> updateRestriction(int id, Restriction restriction) async {
    try {
      var response = await dioInterceptor.dio.put(
        '$baseUrl/api/restrictions/$id',
        data: restriction.toJson(),
      );

      if (response.statusCode == 200) {
        return Restriction.fromJson(response.data);
      } else {
        throw Exception('Failed to update restriction: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception('Failed to update restriction: $error');
    }
  }

  Future<void> deleteRestriction(int id) async {
    try {
      var response = await dioInterceptor.dio.delete('$baseUrl/api/restrictions/$id');

      if (response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to delete restriction: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception('Failed to delete restriction: $error');
    }
  }

  Future<int> getNumberOfRestrictionsByUserId(int userId) async {
    try {
      var response = await dioInterceptor.dio.get('$baseUrl/api/restrictions/user/$userId');

      if (response.statusCode == 200) {
        return response.data as int;
      } else {
        throw Exception('Failed to load number of restrictions: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception('Failed to load number of restrictions: $error');
    }
  }
}
