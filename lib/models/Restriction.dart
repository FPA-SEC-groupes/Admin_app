class Restriction {
  int? id;
  String description;
  int userId;

  Restriction({
    this.id,
    required this.description,
    required this.userId,
  });

  factory Restriction.fromJson(Map<String, dynamic> json) {
    return Restriction(
      id: json['id'],
      description: json['description'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'userId': userId,
    };
  }
}
