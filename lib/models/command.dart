import 'basket.dart';

class Command {
  int idCommand;
  String status;
  DateTime localDate;
  double sum;
  Basket basket;

  Command({
    required this.idCommand,
    required this.status,
    required this.localDate,
    required this.sum,
    required this.basket,
  });

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      idCommand: json['idCommand'],
      status: json['status'],
      localDate: DateTime.parse(json['timestamp']),
      sum: json['sum'],
      basket: Basket.fromJson(json['basket']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCommand': idCommand,
      'status': status,
      'timestamp': localDate.toIso8601String(),
      'sum': sum,
      'basket': basket.toJson(),
    };
  }
}