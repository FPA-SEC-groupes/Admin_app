class Zone {
  int? id;
  String title;

  Zone({
    this.id,
    required this.title,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {

    return Zone(
      id: json['idZone'],
      title: json['zoneTitle'],
        );
  }

  Map<String, dynamic> toJson() => {
    'idZone': id,
    'zoneTitle': title,
  };
}




