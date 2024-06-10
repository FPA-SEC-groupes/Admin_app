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

  Future<List<Shift>> createShift(List<Shift> shifts) async {
    final url = '$baseUrl/api/shiftsystems';
    try {
      // Convert the list of Shift objects to JSON
      List<Map<String, dynamic>> shiftListJson = shifts.map((shift) => shift.toJson()).toList();

      Response response = await dioInterceptor.dio.post(url, data: {'shifts': shiftListJson});

      if (response.statusCode == 200) {
        // Assuming the API returns a list of shifts
        List<dynamic> responseData = response.data;
        List<Shift> createdShifts = responseData.map((shiftData) => Shift.fromJson(shiftData)).toList();
        return createdShifts;
      } else {
        throw Exception("Request failed with status code: ${response.statusCode}");
      }
    } catch (error) {
      print('Error: $error');
      throw Exception("Error: $error");
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
