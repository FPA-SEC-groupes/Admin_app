

  import 'package:hello_way/models/WifiInfo.dart';
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
     int?numberOfRate;
     int? nbReserveOfSpace;
    String? category;
    double surfaceEnM2;
    String? validation;
    List<WifiInfo>? wifis;
    List<ImageModel>? images;
    Space( {
       this.id,
      required this.title,
      required this.latitude,
      required this.longitude,
      required this.description,
      required this.phoneNumber,
      this.validation,
      this.rating,
       this.numberOfRatings,
      this.numberOfRate,
      this.nbReserveOfSpace,
      this.category,
      required this.surfaceEnM2,
      this.wifis,
      this.images,
    });

    factory Space.fromJson(Map<String, dynamic> json) {
      final List<dynamic>? jsonImages = json['images'];
      final List<dynamic>? jsonWifis = json['wifis'];
      final images = jsonImages?.map((image) => ImageModel.fromJson(image)).toList();
      final wifis = jsonWifis?.map((wifi)=>WifiInfo.fromJson(wifi)).toList();
      return Space(
          id: json['id_space'],
          title: json['titleSpace'],
          latitude: double.parse(json['latitude']),
          longitude: double.parse(json['longitude']),
          description: json['description'],
          phoneNumber: json['phoneNumber'],
          rating: json['rating'],
          numberOfRatings: json['numberOfRate'],
          nbReserveOfSpace:json['nbReserveOfSpace'],
          numberOfRate: json['numberOfRate'],
          category: json['spaceCategorie'],
          surfaceEnM2: json['surfaceEnM2'],
          validation:json['validation'],
          images: images,
          wifis: wifis
      );
    }

     Map<String, dynamic> toJson() => {
       'id_space': id,
       'titleSpace': title,
       'latitude': latitude,
       'longitude': longitude,
       'description': description,
       'phoneNumber': phoneNumber,
       'rating': rating,
       'numberOfRate': numberOfRatings,
       'numberOfRate':numberOfRate,
       "nbReserveOfSpace": nbReserveOfSpace,
       'spaceCategorie': category,
       'surfaceEnM2': surfaceEnM2,
       'validation': validation,
       'wifis': wifis?.map((wifi) => wifi.toJson()).toList(),
       'images': images?.map((image) => image.toJson()).toList(),
     };

  }