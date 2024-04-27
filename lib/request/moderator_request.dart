import 'package:hello_way/models/role.dart';

class Moderator {
  int? id;
  String username;
  String email;
  String? password;
  String? phone;
  List<dynamic>? role;
  List<dynamic>? reclamation;
  List<dynamic>? commands;
  List<dynamic>? boards;
  int? moderatorSpace;
  Moderator(
      {required this.username,
        required this.email,
        this.password,
        this.role,
        this.phone,
        this.id,
        this.reclamation,
        this.commands,
        this.boards,
        this.moderatorSpace});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'roles': role
    };
  }

  factory Moderator.fromJson(Map<String, dynamic> json) {
    return Moderator(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['roles'],
      reclamation: json['reclamation'],
      commands: json['commands'],
      boards: json['boards'],
      moderatorSpace: json['moderatorSpace'],
    );
  }
}