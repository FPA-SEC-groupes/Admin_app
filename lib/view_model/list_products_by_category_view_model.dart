import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/category.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/product.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class ListProductsViewModel{

  final DioInterceptor dioInterceptor;
  ListProductsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);



  Future<Category> getCategorieId(int idCategory) async {
    try {
      final response = await dioInterceptor.dio.get('$baseUrl/api/categories/id/$idCategory');
      if (response.statusCode == 200) {
        final Category categorie = Category.fromJson(response.data) ;

        return categorie;
      } else {
        // Handle HTTP error
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<void> updateProductOrder(List<Product> products) async {
    final url = '$baseUrl/api/products/updateOrder';

    try {
      // Create a list of product IDs in the new order
      List<int?> productIds = products.map((product) => product.idProduct).toList();

      final response = await dioInterceptor.dio.put(
        url,
        data: json.encode({'productIds': productIds}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update product order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating product order: $e');
    }
  }


}