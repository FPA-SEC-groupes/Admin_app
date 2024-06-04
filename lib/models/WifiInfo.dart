class WifiInfo {
  int? id;
  String ssid;
  String password;

  WifiInfo({required this.ssid, required this.password});

  // From JSON
  factory WifiInfo.fromJson(Map<String, dynamic> json) {
    return WifiInfo(
      ssid: json['ssid'],
      password: json['password'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
    };
  }
}
