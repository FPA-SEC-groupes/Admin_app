

import 'package:hello_way/models/image.dart';

class Space {
   int? id;
   String title;
   double latitude;
   double longitude;
   String description;
   int phoneNumber;
   num? rating;
   int? numberOfRatings;
  String? category;
  double surfaceEnM2;
  List<ImageModel>? images;
  Space( {
     this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.phoneNumber,
    this.rating,
     this.numberOfRatings,
    this.category,
    required this.surfaceEnM2,
    this.images,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? jsonImages = json['images'];
    final images = jsonImages?.map((image) => ImageModel.fromJson(image)).toList();

    return Space(
        id: json['id_space'],
        title: json['titleSpace'],
        latitude: double.parse(json['latitude']),
        longitude: double.parse(json['longitude']),
        description: json['description'],
        phoneNumber: json['phoneNumber'],
        rating: json['rating'],
        numberOfRatings: json['numberOfRate'],
        category: json['spaceCategorie'],
        surfaceEnM2: json['surfaceEnM2'],
        images: images
    );
  }

  Map<String, dynamic> toJson() => {
    'id_space': id,
    'titleSpace': title,
    'latitude': latitude,
    'longitude': longitude,
    'description': description,
    'phoneNumber':phoneNumber,
    'rating': rating,
    'numberOfRate': numberOfRatings,
    'spaceCategorie': category,
    'surfaceEnM2':surfaceEnM2,
    'images': images?.map((image) => image.toJson()).toList(),

  };
}