import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hello_way/models/product.dart';

import '../interceptors/dio_interceptor.dart';
import '../response/ProductResponse.dart';
import '../utils/const.dart';
import 'package:http_parser/http_parser.dart';

class ProductsViewModel {
  final DioInterceptor dioInterceptor;
  ProductsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  Future<ProductResponse> addProductByIdCategory(
      String categoryId, Product product) async {

      // Define the API endpoint URL
      final url = '$baseUrl/api/products/add/id_categorie/$categoryId';
      final response = await dioInterceptor.dio.post(
        url,
        data: product.toJson(),
      );

      if (response.statusCode == 200) {

        var product = ProductResponse.fromJson(response.data);
        return product;
      } else {
        print('Failed to add product. Error code: ${response.statusCode}');
        throw Exception("Failed to add product.");
      }
  }

  Future<void> uploadImage(File image, int productId) async {
    final uri = '$baseUrl/api/products/$productId/images';

    String fileName = image.path.split("/").last;

    Uint8List bytes = await image.readAsBytes();

    // Compress the image before uploading
    final compressedFile = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 1920,
      minWidth: 1080,
      quality: 90,
    );

    // Convert the compressed file to a multipart file
    MultipartFile multipartFile = MultipartFile.fromBytes(compressedFile,
        filename: fileName,
        contentType: MediaType('image', fileName.split('.').last));
    final formData = FormData.fromMap({'file': multipartFile});
    var response = await dioInterceptor.dio.post(
      uri,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.statusCode == 200) {
      print('Image added successfully!');
    } else {
      print('Failed to add image. Error code: ${response.statusCode}');
      throw Exception("Failed to add image.");
    }
    print('success');
  }
  Future<Product> updateProduct(Product product, int productId) async {

      String url = '$baseUrl/api/products/update/$productId';
     // Assuming your Product model has a toJson() method to convert it to a Map

      Response response = await dioInterceptor.dio.put(url, data: product.toJson());

      if (response.statusCode == 200) {
        var product = Product.fromJson(response.data);
        return product;
      } else {
        print('Failed to update product. Error code: ${response.statusCode}');
        throw Exception("Failed to update product.");
      }

  }


  Future<void> deleteProduct(int id) async {
    final String url = '$baseUrl/api/products/delete/$id';

    try {
      final response = await dioInterceptor.dio.delete(
        url,
      );

      if (response.statusCode == 200) {
        // Product deleted successfully
        print('Product with ID $id deleted successfully.');
      }
    } catch (error) {
      // Handle errors, e.g., connection issues, timeouts, etc.
      print('Error deleting product: $error');
    }
  }
}
