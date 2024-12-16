import 'package:hello_way/models/user.dart';
import 'package:hello_way/models/reservation.dart';

class Restriction {
  int? id;
  String description;
  User? user;
  Reservation? reservation;

  Restriction({
    required this.description,
    this.user,
    this.reservation,
    this.id,
  });

  factory Restriction.fromJson(Map<String, dynamic> json) {
    return Restriction(
      id: json['id'],
      description: json['description'] ?? "No restriction",
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      reservation: json['reservation'] != null ? Reservation.fromJson(json['reservation']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'description': description,
      'userId': user?.id,
      'reservationId': reservation?.idReservation,
    };
    return data;
  }
}
