
class Category {
  int? id_category;
  String categoryTitle;


  Category({
    this.id_category,
    required this.categoryTitle,

  });

  factory Category.fromJson(Map<String, dynamic> json) {


    return Category(
      id_category: json['id_category'],
      categoryTitle: json['categoryTitle'],

    );
  }

  Map<String, dynamic> toJson() => {
    'id_category': id_category,
    'categoryTitle': categoryTitle,
  };
}




