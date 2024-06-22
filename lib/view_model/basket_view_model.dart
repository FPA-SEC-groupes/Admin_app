import 'package:flutter/material.dart';
import '../../models/command.dart';
import '../../models/user.dart';
import '../../response/product_with_quantity.dart';
import '../../models/notifcation.dart' as notification;
import '../interceptors/dio_interceptor.dart';
import '../utils/const.dart';
import 'package:dio/dio.dart';

import '../utils/secure_storage.dart';

class BasketViewModel {
  final DioInterceptor dioInterceptor;
  BasketViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);

  Dio dio = Dio();
  final SecureStorage secureStorage = SecureStorage();
  // Future<String?> validateSessionForUsers(String tableId) async {
  //   final sessionId = await secureStorage.readData(sessionIdKey);
  //   final jwtCookie = await secureStorage.readData('jwtToken');
  //   // Define the API endpoint URL
  //
  //   final url = '$baseUrl/api/sessions/validate-session/latest/$tableId';
  //   final response = await dio.get(url,
  //       options: Options(
  //         headers: {
  //           'cookie': jwtCookie,
  //           'Cookie': 'JSESSIONID=$sessionId',
  //         },
  //       ));
  //
  //   // Handle the response from the API
  //   if (response.statusCode == 200) {
  //     final data = response.data;
  //     print(data);
  //     if (data == 'First session') {
  //       return 'First session';
  //     } else {
  //       return 'Not the first session';
  //     }
  //   }
  //
  // }

  Future<void> addProductToBasket(int productId, int quantity,int basketId) async {
    print("oooooooooooooooooooooooooooooooooooooooooooooooooooo");
    // final basketId = await secureStorage.readData(basketIdKey);
    final url =
        '$baseUrl/api/baskets/add/product/$productId/to_basket/$basketId/quantity/$quantity';

    try {
      final response = await dioInterceptor.dio.post(url);

      if (response.statusCode == 200) {


      } else {
        print('Failed to add product to basket. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Future<void> getLatestBasketByIdTable(String tableId, ) async {
  //   final url = '$baseUrl/api/baskets/latest/basket/by_table/$tableId';
  //   final response = await dioInterceptor.dio.get(url);
  //
  //   // Handle the response from the API
  //   if (response.statusCode == 200) {
  //     final data = response.data;
  //     await secureStorage.writeData(basketIdKey, data['id_basket'].toString());
  //   } else {
  //     throw Exception('Failed to load categories: ${response.statusCode}');
  //   }
  // }


  Future<List<ProductWithQuantities1>> getProductsByBasketId(int basketId) async {
    try {
      // final basketId = await secureStorage.readData(basketIdKey);

      final response =
      await dioInterceptor.dio.get('$baseUrl/api/baskets/products/by_basket/$basketId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<ProductWithQuantities1> products =
        parsedJson.map((json) => ProductWithQuantities1.fromJson(json)).toList();
        print(products.toString());
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }


  Future<Command> addNewCommand() async {
    try {
      final basketId = await secureStorage.readData(basketIdKey);
      final userId = await secureStorage.readData(authentifiedUserId);
      String url = "$baseUrl/api/baskets/$basketId/commands/add/user/$userId";

      Response response = await dioInterceptor.dio.post(url);

      if (response.statusCode == 200) {
        final command=Command.fromJson(response.data);
        print(response.data);

        return command;
      } else {
        throw Exception('Failed to create command.');
        // Handle the error response as per your requirements
      }
    } catch (e) {
      throw Exception("Error: $e");
      // Handle the error as per your requirements
    }
  }


  Future<void> updateCommand(String commandId) async {
    final basketId = await secureStorage.readData(basketIdKey);
    String url = '$baseUrl/api/commands/update/$commandId/basket/$basketId';

    try {
      Response response = await dioInterceptor.dio.put(url);

      if (response.statusCode == 200) {
        // Request successful
        print('Command updated');
      } else {
        // Request failed
        print('Request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      // Error during the request
      print('Error: $error');
    }
  }


  Future<void> deleteProductFromBasket(int productId,int  basketId) async {
    // final basketId = await secureStorage.readData(basketIdKey);
    try {
      final response = await dioInterceptor.dio.post(
        '$baseUrl/api/baskets/delete/product/$productId/from_basket/$basketId',
      );

      if (response.statusCode == 200) {
        print('Product deleted successfully');
      } else {
        print('Failed to delete product');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<Command?> fetchCommandByBasketId() async {
    final basketId= await secureStorage.readData(basketIdKey);
    Response response = await dioInterceptor.dio.get(
      "$baseUrl/api/commands/by/basket/$basketId",
    );

    if (response.statusCode == 200) {

      if(response.data!=""){
        print(response.data);
        return Command.fromJson(response.data);
      }
    }

    return null;
  }

  Future<User> fetchServerByCommandId(int commandId) async {

    final response = await dioInterceptor.dio.get(
      "$baseUrl/api/commands/command_id/$commandId",
    );

    if (response.statusCode == 200) {
      print(response.data);
      final user=User.fromJson(response.data);
      return user;
    } else {
      throw Exception('Failed to load server: ${response.statusCode}');

    }

  }


  Future<notification.Notification> createNotification(User user, String title ,String message) async {
    final response = await dioInterceptor.dio.post(
      "$baseUrl/api/notifications/create",
      data: user.toJson(),
      queryParameters: {
        "title": title,
        "message":message,
      },
    );

    if (response.statusCode == 200) {
      final notif=notification.Notification.fromJson(response.data);
      return notif;
    } else {
      throw Exception('Failed to create notification: ${response.statusCode}');
    }

  }
}
