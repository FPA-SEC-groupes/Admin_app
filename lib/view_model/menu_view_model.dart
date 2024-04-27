import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/category.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/product.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class MenuViewModel {
  final DioInterceptor dioInterceptor;
  MenuViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();
  Future<Category> addCategoryByIdSpace(
      BuildContext context, String categoryTitle) async {
      final spaceId = await secureStorage.readData(spaceIdKey);
      final url = '$baseUrl/api/categories/add/id_space/$spaceId';
      final requestBody = json.encode({
        'categoryTitle': categoryTitle,
      });
      // Send the request to the API endpoint using the dioInterceptor
      final response = await dioInterceptor.dio.post(
        url,
        data: requestBody,
      );
      // Handle the response from the API
      if (response.statusCode == 200) {
        final Category category = Category.fromJson(response.data);
        ;
        return category;
      } else {
        // Category addition failed, display an error message to the user
        print('Failed to add category. Error code: ${response.statusCode}');
        throw Exception("Failed to add category.");
      }

  }

/*
  final StreamController<List<Category>> _categoriesStreamController =
  StreamController<List<Category>>.broadcast();

  Stream<List<Category>> get categoriesStream =>
      _categoriesStreamController.stream;

  Future<void> getCategoriesByIdSpace() async {
    try {
      final response =
      await dioInterceptor.dio.get('$baseUrl/api/categories/id_space/1');
      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<Category> categories = parsedJson
            .map((json) => Category.fromJson(json))
            .toList();
        _categoriesStreamController.add(categories);
      } else {
        // Handle HTTP error
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to load categories: $e');
    }
  }

  void dispose() {
    _categoriesStreamController.close();
  }
*/
  Future<List<Category>> getCategoriesByIdSpace() async {
    try {
      final spaceId = await secureStorage.readData(spaceIdKey);
      final response = await dioInterceptor.dio
          .get('$baseUrl/api/categories/id_space/$spaceId');
      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;

        final List<Category> categories =
            parsedJson.map((json) => Category.fromJson(json)).toList();
        return categories;
      } else {
        // Handle HTTP error
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<Product>> getProductsByIdCategory(int categoryId) async {
    try {
      final response = await dioInterceptor.dio
          .get('$baseUrl/api/products/all/dto/id_categorie/$categoryId');

      if (response.statusCode == 200) {
        print(response.data);
        final List<dynamic> parsedJson = response.data;
        final List<Product> products =
            parsedJson.map((json) => Product.fromJson(json)).toList();
        return products;
      }else {
        // Handle other HTTP errors
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 404) {
        return [];
      } else {
        throw Exception("Failed to load products" + error.toString());
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteCategorie(int id) async {
    final url = '$baseUrl/api/categories/delete/$id';

    try {
      final response = await dioInterceptor.dio.delete(url);

      if (response.statusCode == 200) {
        // The category was successfully deleted
        print('Category with ID $id was deleted successfully.');
      } else {
        // Handle other status codes here if needed
        print('Failed to delete category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occurred during the request
      print('Error deleting category: $e');
    }
  }

  Future<Category> updateCategory(Category category) async {
      // Send the PUT request with the updated zone object as the request body
      final response = await dioInterceptor.dio.put(
        '$baseUrl/api/categories/update/${category.id_category}',
        data: category.toJson(),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Category category = Category.fromJson(response.data);;
        return category;
      } else {
        // Handle other status codes (if needed)
        throw Exception('Failed to update category: ${response.statusCode}');
      }

  }
}
