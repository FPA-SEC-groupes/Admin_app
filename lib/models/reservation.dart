

class Reservation {
   int? idReservation;
   String status;
   String eventTitle;
   int numberOfGuests;
   DateTime bookingDate;
   DateTime? cancelDate;
   DateTime startDate;
   DateTime? confirmedDate;
   String? description;

  Reservation({
     this.idReservation,
    required this.status,
    required this.eventTitle,
    required this.numberOfGuests,
    required this.bookingDate,
     this.cancelDate,
    required this.startDate,
    this.confirmedDate,
    this.description,
  });


   factory Reservation.fromJson(Map<String, dynamic> json) {
     return Reservation(
       idReservation: json['idReservation'],
       status: json['status'],
       eventTitle: json['eventTitle'],
       numberOfGuests: json['numberOfGuests'],
       bookingDate: DateTime.parse(json['bookingDate']),
       cancelDate: json['cancelDate'] != null ? DateTime.parse(json['cancelDate']) : null,
       startDate: DateTime.parse(json['startDate']),
       confirmedDate: json['confirmedDate'] != null ? DateTime.parse(json['confirmedDate']) : null,
       description: json['description'],
     );
   }

   Map<String, dynamic> toJson() {
     return {
       'idReservation': idReservation,
       'status': status,
       'eventTitle': eventTitle,
       'numberOfGuests': numberOfGuests,
       'bookingDate': bookingDate.toIso8601String(),
       'cancelDate': cancelDate != null ? cancelDate!.toIso8601String() : null,
       'startDate': startDate.toIso8601String(),
       'confirmedDate': confirmedDate != null ? confirmedDate!.toIso8601String() : null,
       'description': description,
     };
   }
}

