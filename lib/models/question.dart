class Question {
  final String question;
  int voting;
  String status;
  List<String> answers;
  List<int> counterAnswer;
  double _percentValue;

  Question(this.question, this.answers, this.counterAnswer, [this.status = 'Wird geprüft', this.voting = 0]);

  /// Berechnet Prozentwert für übergebene Antwort.
  /// multiply = false : 0.58 (Default)
  /// multiply = true  : 0.58 wird mit 100 multipliziert => 58.
  /// return z.B. 0.58 oder 58.
  double calculatePercentValue(int answer, [bool multiply = false]) {
    _percentValue = 0.0;
    if (counterAnswer[0] == 0 && counterAnswer[1] == 0) {
      return _percentValue;
    }
    if (answer == 1) {
      _percentValue = counterAnswer[0] / (counterAnswer[0] + counterAnswer[1]);
    } else if (answer == 2) {
      _percentValue = counterAnswer[1] / (counterAnswer[0] + counterAnswer[1]);
    }
    if (multiply) {
      _percentValue *= 100;
    }
    return _percentValue;
  }

  /// Berechnet die Gesamtanzahl an Antworten für eine Frage.
  int calculateOverallAnswerValue(int counterAnswer1, int counterAnswer2) {
    return counterAnswer1 + counterAnswer2;
  }
}