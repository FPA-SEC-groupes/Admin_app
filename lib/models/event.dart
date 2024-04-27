import 'dart:ui';

import 'package:hello_way/models/product.dart';

class Event {
  int? idEvent;
  String eventTitle;
  DateTime startDate;
  DateTime endDate;
  String description;
  int? percentage;
  Product? product;
  int? nbParticipant ;
  double? price ;
  bool? allInclusive ;
  Color? background;

  Event({
    this.idEvent,
    required this.eventTitle,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.percentage,
     this.product,
    this.price,
    this.nbParticipant,
    this.allInclusive
  });



  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      idEvent: json['idEvent'],
      eventTitle: json['eventTitle'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      description: json['description'],
      percentage: json['percentage'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      nbParticipant: json['nbParticipant'],
      price: json['price'],
      allInclusive: json['allInclusive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEvent': idEvent,
      'eventTitle': eventTitle,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'percentage': percentage,
      'product': product != null ? product!.toJson() : null,
      'nbParticipant': nbParticipant,
      'price': price,
      'allInclusive': allInclusive,
    };
  }
}
