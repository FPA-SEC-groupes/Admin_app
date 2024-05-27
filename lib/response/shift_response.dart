import '../models/shift.dart';

class ShiftResponse {
  final List<Shift> shifts;

  ShiftResponse({required this.shifts});

  factory ShiftResponse.fromJson(Map<String, dynamic> json) {
    return ShiftResponse(
      shifts: (json['shifts'] as List).map((i) => Shift.fromJson(i)).toList(),
    );
  }
}
