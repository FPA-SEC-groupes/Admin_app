class Shift {
  final int? shiftId;
  final int waiterId;
  final String type;
  final String date;
  String startTime; // Removed `late final` to allow mutability
  String endTime;   // Removed `late final` to allow mutability

  Shift({
    this.shiftId,
    required this.waiterId,
    required this.type,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      shiftId: json['id'] as int?,
      waiterId: json['waiter']['id'] as int,
      type: json['type'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiftId': shiftId,
      'waiterId': waiterId,
      'type': type,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
  @override
  String toString() {
    return 'Shift(waiterId: $waiterId, type: $type, date: $date, startTime: $startTime, endTime: $endTime)';
  }
}
