import 'dart:ui';

class ProductResponse
{
  int idProduct;
  String productTitle;
  double price;
  String description;

  ProductResponse({
    required this.idProduct,
    required this.productTitle,
    required this.price,
    required this.description,

  });


  factory ProductResponse.fromJson(Map<String, dynamic> json) {


    return ProductResponse(
        idProduct: json['idProduct'],
        productTitle: json['productTitle'],
        price: json['price'],
        description: json['description'],

    );
  }


  Map<String, dynamic> toJson() => {
    'idProduct': idProduct,
    'productTitle': productTitle,
    'price': price,
    'description': description,

  };
}