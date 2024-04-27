class ResetPasswordRequest {
  String email;
  String newPassword;

  ResetPasswordRequest({ required this.email,required this.newPassword});

  Map<String, dynamic> toJson() {
    return {
      'email': email,

      'newPassword': newPassword,
    };
  }

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      email: json['email'],
      newPassword: json['newPassword'],
    );
  }
}