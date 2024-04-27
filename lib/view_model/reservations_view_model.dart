import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_way/utils/const.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/reservation.dart';
import '../utils/secure_storage.dart';

class ReservationsViewModel {
  final SecureStorage secureStorage = SecureStorage();

  final DioInterceptor dioInterceptor;
  ReservationsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);



  Future<List<Reservation>> getReservationsBySpaceId() async {
    String? spaceId = await secureStorage.readData(spaceIdKey);
    try {
      var response = await dioInterceptor.dio.get('$baseUrl/api/reservations/space/$spaceId');

      if (response.statusCode == 200) {
        var reservationList = (response.data as List)
            .map((json) => Reservation.fromJson(json))
            .toList();
        return reservationList;
      } else {
        // Handle errors based on the response status code
        throw Exception('failed to load reservations: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Exception: $error');
      throw Exception('failed to load reservations: $error');
    }
  }



  Future<Reservation> acceptReservation(int reservationId) async {
    final url='$baseUrl/api/reservations/$reservationId/accept';
    try {
      Response response = await dioInterceptor.dio.post(
        url, // Replace with your actual API endpoint URL
      );
      if (response.statusCode == 200) {
        print(response.data);
        Reservation updatedReservation = Reservation.fromJson(response.data);
        print('Reservation refused successfully!');
        return updatedReservation;
      } else {
        throw Exception('failed to load');
      }
    } catch (error) {
      throw Exception('failed : $error');
    }
  }

  Future<Reservation> refuseReservation(int reservationId) async {
    final url='$baseUrl/api/reservations/$reservationId/refuse';
    try {
      Response response = await dioInterceptor.dio.post(
        url, // Replace with your actual API endpoint URL
      );
      if (response.statusCode == 200) {
        print(response.data);
        Reservation updatedReservation = Reservation.fromJson(response.data);
        return updatedReservation;
      } else {
        throw Exception('failed to load');
      }
    } catch (error) {
      throw Exception('failed : $error');
    }
  }


  Future<Reservation> assignReservationToTables(List<int> boardIds, int reservationId) async {
    final url='$baseUrl/api/reservations/assign/reservation/$reservationId';

    final response = await dioInterceptor.dio.post(url, data: boardIds);

    if (response.statusCode == 200) {
      print(response.data);
      Reservation updatedReservation = Reservation.fromJson(response.data);
      return updatedReservation;
    } else {
      // Request failed
      throw Exception('Failed to assign reservation to tables. Status code: ${response.statusCode}');

    }
  }

}