import 'package:hello_way/models/zone.dart';

class User {
  int? id;
  String username;
  String? name;
  String? lastname;
  String email;
  String? password;
  String? phone;
  String? image;
  bool? activated;
  List<dynamic>? role;

  User({ required this.username,this.name,this.lastname,required this.email, this.password, this.role, this.phone,this.id,this.image, this.activated});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'name': name,
      'phone': phone,
      'lastname': lastname,
      'password': password,
    };
    if (id != null) {
      data['id'] = id;
    }
    if (role != null) {
      data['role'] = role;
    }
    if (activated != null) {
      data['activated'] = activated;
    }

    return data;
  }

  factory User.fromJson(Map<String, dynamic> json) {

    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      lastname: json['lastname'],
      phone: json['phone'],
      email: json['email'],
      role: json['roles'],
      activated: json['activated'],
      image: json['image']!=null? json['image']['data']:null,

    );
  }
}
