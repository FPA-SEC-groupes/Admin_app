import 'package:hello_way/models/ProductStatus.dart';

import '../models/product.dart';


class ProductWithQuantities1 {
  final Product product;
  final int quantity;
  final int oldQuantity;
  final ProductStatus status;
  ProductWithQuantities1( {required this.product,required this.quantity,required this.oldQuantity,required this.status,});

  factory ProductWithQuantities1.fromJson(Map<String, dynamic> json) {
    return ProductWithQuantities1(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      oldQuantity: json['oldQuantity'],
      status: ProductStatus.values.firstWhere((e) => e.toString() == 'ProductStatus.${json['status']}'),
    );
  }
  @override
  String toString() {
    return 'ProductWithQuantities{product: $product, quantity: $quantity}';
  }
}