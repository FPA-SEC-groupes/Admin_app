import '../models/product.dart';

class ProductWithQuantities {
  final Product product;
  final int quantity;
  final int oldQuantity;
  ProductWithQuantities( {required this.product,required this.quantity,required this.oldQuantity});

  factory ProductWithQuantities.fromJson(Map<String, dynamic> json) {
    return ProductWithQuantities(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      oldQuantity: json['oldQuantity'],
    );
  }
}