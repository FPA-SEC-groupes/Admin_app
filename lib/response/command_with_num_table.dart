

import '../models/command.dart';

class CommandWithNumTable {
  final Command command;
  final int numTable;
  CommandWithNumTable({required this.command,required this.numTable});

  factory CommandWithNumTable.fromJson(Map<String, dynamic> json) {
    return CommandWithNumTable(
      command: Command.fromJson(json['command']),
      numTable: json['numTable'],
    );
  }
}