

import 'package:hello_way/models/image.dart';

class Product
{
  int? idProduct;
  String productTitle;
  double price;
  String description;
  bool available;
  dynamic categorie;
  List<ImageModel>? images;
  bool? hasActivePromotion;
  int? percentage;
  int? promotionId;
  Product({
    this.idProduct,
    required this.productTitle,
    required this.price,
    required this.description,
    required this.available,
    this.categorie,
    this.images,
    this.hasActivePromotion,
    this.percentage,
    this.promotionId
  });


  factory Product.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonImages = json['images'];
    final images = jsonImages.map((image) => ImageModel.fromJson(image)).toList();

    return Product(
        idProduct: json['idProduct'],
        productTitle: json['productTitle'],
        price: json['price'],
        description: json['description'],
        categorie: json['categorie'],
        available: json['available'],
        hasActivePromotion: json['hasActivePromotion'],
        percentage: json['percentage'],
        promotionId: json['promotionId'],
        images: images
    );
  }


  Map<String, dynamic> toJson() => {
    'idProduct': idProduct,
    'productTitle': productTitle,
    'price': price,
    'description': description,
    'categorie': categorie,
    'available':available,
    'hasActivePromotion':hasActivePromotion,
    'percentage':percentage,
    'images': images?.map((image) => image.toJson()).toList(),
  };
}


