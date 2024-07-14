class LoginRequest {

  String username;
  String password;
  String token;

  LoginRequest({ required this.username,required this.password, required this.token});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'token':token

    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(

      username: json['username'],
      password: json['password'],
      token:json['token']
    );
  }
}