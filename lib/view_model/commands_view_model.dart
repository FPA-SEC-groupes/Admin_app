


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/response/command_with_num_table.dart';

import '../interceptors/dio_interceptor.dart';
import '../response/product_with_quantities.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class CommandsViewModel {
  final DioInterceptor dioInterceptor;
  CommandsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();

Future<List<CommandWithNumTable>> getCommandsByWaiterId(String status) async {
  final waiterId = await secureStorage.readData(authentifiedUserId);
  try {
    final response = await dioInterceptor.dio.get('$baseUrl/api/commands/for/server/$waiterId');

    if (response.statusCode == 200) {
      final List<dynamic> parsedJson = response.data;
      print(response.data);
      if(status=="ALL"){
        final List<CommandWithNumTable> commands =
        parsedJson.map((json) => CommandWithNumTable.fromJson(json))
            .toList();
        return commands;
      }
     else{
        final List<CommandWithNumTable> commands =
        parsedJson.map((json) => CommandWithNumTable.fromJson(json)) .where((command) => command.command.status == status)
            .toList();
        return commands;

      }

    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load products: $e');
  }
}



  Future<double> getSumOfCommand(int commandId) async {
    try {
      final response = await dioInterceptor.dio.get('$baseUrl/api/commands/calculate/sum/$commandId');

      if (response.statusCode == 200) {
        return response.data as double;
      } else {
        // Handle other status codes
        return 0.0;
      }
    } catch (e) {
      // Handle exceptions
      return 0.0;
    }
  }



  Future<List<ProductWithQuantities>> getProductsByCommandId(int commandId) async {
    try {
      final response =
      await dioInterceptor.dio.get('$baseUrl/api/baskets/products/by_command/$commandId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<ProductWithQuantities> products = parsedJson.map((json) => ProductWithQuantities.fromJson(json)).toList();
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }



  Future<String?> acceptCommand(int commandId) async {
  final url='$baseUrl/api/commands/$commandId/accept';
    try {
      Response response = await dioInterceptor.dio.post(
        url, // Replace with your actual API endpoint URL
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Failed to accept command');
      }
    } catch (error) {
      print('Error: $error');
    }
    return null;
  }

  Future<void> refuseCommand(int commandId) async {
    final url='$baseUrl/api/commands/$commandId/refuse';
    try {
      Response response = await dioInterceptor.dio.post(
        url, // Replace with your actual API endpoint URL
      );
      if (response.statusCode == 200) {
        print('Command refused');
      } else {
        print('Failed to accept command');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  Future<void> payCommand(int commandId) async {
    final url='$baseUrl/api/commands/$commandId/pay';
    try {
      Response response = await dioInterceptor.dio.post(
        url, // Replace with your actual API endpoint URL
      );
      if (response.statusCode == 200) {
        print('Command refused');
      } else {
        print('Failed to accept command');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}