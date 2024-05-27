import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/interceptors/dio_interceptor.dart';
import 'package:hello_way/models/shift.dart';
import 'package:hello_way/utils/const.dart';
import 'package:hello_way/utils/secure_storage.dart';

class ShiftViewModel {
  final DioInterceptor dioInterceptor;

  ShiftViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();

  Future<void> saveShift(int waiterId,
      List<Map<String, String>> shiftTimes) async {
    final url = '$baseUrl/api/shiftsystems';
    Map<String, dynamic> requestBody = {
      'waiterId': waiterId,
      'shiftTimes': shiftTimes,
    };
  print(shiftTimes);
    try {
      Response response = await dioInterceptor.dio.post(
        url,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        print('Shift saved successfully');
      } else {
        print('Failed to save shift: ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        // DioError with response
        print('Dio error occurred: ${e.response!.statusCode} ${e.response!
            .data}');
      } else {
        // Error before response is available
        print('Dio error before response: ${e.message}');
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }

  Future<List<Shift>> getShiftsByWaiterId() async {
    final waiterId = await secureStorage.readData(authentifiedUserId);
    final url = '$baseUrl/api/shiftsystems/waiter/$waiterId';

    try {
      Response response = await dioInterceptor.dio.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<Shift> shifts = data.map((dynamic item) => Shift.fromJson(item as Map<String, dynamic>)).toList();
        return shifts;
      } else {
        throw Exception('Failed to retrieve shifts: HTTP ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception('Dio error: ${e.response!.statusCode} ${e.response!.data}');
      } else {
        throw Exception('Dio error before response: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  Future<List<Shift>> getShiftsByWaiterId1(int  waiterId) async {
    final url = '$baseUrl/api/shiftsystems/waiter/$waiterId';

    try {
      Response response = await dioInterceptor.dio.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<Shift> shifts = data.map((dynamic item) => Shift.fromJson(item as Map<String, dynamic>)).toList();
        print(shifts);
        return shifts;
      } else {
        throw Exception('Failed to retrieve shifts: HTTP ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception('Dio error: ${e.response!.statusCode} ${e.response!.data}');
      } else {
        throw Exception('Dio error before response: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  Future<void> updateShift(Shift shift) async {
    print('shif'+shift.toString());
    final url = '$baseUrl/api/shiftsystems/${shift.shiftId}';
    try {
      final response = await dioInterceptor.dio.put(url, data: shift.toJson());
      if (response.statusCode == 200) {
        print("Shift updated successfully");
      } else {
        print("Failed to update shift: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to update shift: $e");
    }
  }
}
