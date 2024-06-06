import 'package:hello_way/models/user.dart';

class Zone {
  int? id;
  String title;
  User? server; // Changed from 'user' to 'server'
  Zone({
    this.id,
    required this.title,
    this.server,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['idZone'],
      title: json['zoneTitle'],
      server: json['server'] != null ? User.fromJson(json['server']) : null, // Parse the 'server' field as a User object
    );
  }

  Map<String, dynamic> toJson() => {
    'idZone': id,
    'zoneTitle': title,
    'server': server?.toJson(), // Convert the 'server' object to a JSON object
  };
}
