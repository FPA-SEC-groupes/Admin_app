
class Basket {
  int id_basket;
  List<dynamic>? basketProducts;

  Basket({
    required this.id_basket,
    required this.basketProducts,
  });

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      id_basket: json['id_basket'],
      basketProducts: json['basketProducts']

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_basket': id_basket,
      'basketProducts': basketProducts
    };
  }
}