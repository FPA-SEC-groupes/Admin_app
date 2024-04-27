class PrimaryMaterial {
   int? id;
   String title;
   String description;
   String unitOfMeasure;
   double stockQuantity;
   double price;
   DateTime expirationDate;
   String supplier;
   String supplierNumber;

  PrimaryMaterial({
    this.id,
    required this.title,
    required this.description,
    required this.unitOfMeasure,
    required this.stockQuantity,
    required this.price,
    required this.expirationDate,
    required this.supplier,
    required this.supplierNumber,
  });

  factory PrimaryMaterial.fromJson(Map<String, dynamic> json) {
    return PrimaryMaterial(
      id: json['id'],
      title: json['name'],
      description: json['description'],
      unitOfMeasure: json['unitOfMeasure'],
      stockQuantity: json['stockQuantity'],
      price: json['price'],
      expirationDate: DateTime.parse(json['expirationDate']),
      supplier: json['supplier'],
      supplierNumber: json['supplierNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': title,
      'description': description,
      'unitOfMeasure': unitOfMeasure,
      'stockQuantity': stockQuantity,
      'price': price,
      'expirationDate': expirationDate.toIso8601String(),
      'supplier': supplier,
      'supplierNumber': supplierNumber,
    };
  }
}
