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




}