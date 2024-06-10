import 'package:hello_way/models/image.dart';
import 'package:hello_way/models/event.dart';

class Product {
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
  List<Event>? promotions;

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
    this.promotionId,
    this.promotions,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonImages = json['images'] ?? [];
    final images = jsonImages.map((image) => ImageModel.fromJson(image)).toList();

    final List<dynamic> jsonPromotions = json['promotions'] ?? [];
    print('promotions ${json['promotions']}');
    final promotions = jsonPromotions.map((promotion) => Event.fromJson(promotion)).toList();

    int? percentage;
    int? promotionId;

    if (promotions.isNotEmpty) {
      percentage = promotions.first.percentage;
      promotionId = promotions.first.idEvent;
    }

    return Product(
      idProduct: json['idProduct'],
      productTitle: json['productTitle'],
      price: json['price'],
      description: json['description'],
      categorie: json['categorie'],
      available: json['available'],
      hasActivePromotion: json['hasActivePromotion'],
      percentage: percentage,
      promotionId: promotionId,
      images: images,
      promotions: promotions,
    );
  }

  Map<String, dynamic> toJson() => {
    'idProduct': idProduct,
    'productTitle': productTitle,
    'price': price,
    'description': description,
    'categorie': categorie,
    'available': available,
    'hasActivePromotion': hasActivePromotion,
    'percentage': percentage,
    'promotionId': promotionId,
    'images': images?.map((image) => image.toJson()).toList(),
    'promotions': promotions?.map((promotion) => promotion.toJson()).toList(),
  };
}
