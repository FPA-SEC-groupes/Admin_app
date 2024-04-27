class Board {
  int? id;
  int numTable;
  bool availability;
  int placeNumber;

  Board({
    this.id,
    required this.numTable,
    required this.availability,
    required this.placeNumber,
  });

  factory Board.fromJson(Map<String, dynamic> json) {

    return Board(
      id: json['idTable'],
      numTable: json['numTable'],
      availability: json['availability'],
      placeNumber: json['placeNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'numTable': numTable,
      'availability': availability,
      'placeNumber': placeNumber,
    };

    // Check if tableId is not null, and include it in the JSON if it exists
    if (id != null) {
      data['idTable'] = id;
    }

    return data;
  }
}




