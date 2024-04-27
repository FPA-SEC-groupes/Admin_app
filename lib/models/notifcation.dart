class Notification {
   int id;
   String title;
   String message;
   bool seen;
   DateTime date;


  Notification({required this.id,required this.title, required this.message,required this.seen,required this.date});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['notificationTitle'],
      message: json['message'],
      seen: json['seen'],
      date: DateTime.parse(json['creationDate']),
      // Map other properties here
    );
  }
}