class RecordsOfSession {
  final int id;
  final String duration;
  final String time;
  final String type;

  RecordsOfSession({required this.id, required this.duration, required this.time, required this.type});
}

class TypeOfSession {
  int totalDuration;
  final String type;

  TypeOfSession({required this.totalDuration, required this.type});
}

class TypeOfDuration {
  final String typeOfDuration;
  int duration;
  int numberOfRepetition;

  TypeOfDuration({required this.typeOfDuration, required this.duration, required this.numberOfRepetition});
}
