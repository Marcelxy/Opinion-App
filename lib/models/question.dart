class Question {
  final String qid;
  final String question;
  int voting;
  String status;
  String creatorUsername;
  List<String> answers;
  List<int> counterAnswer;

  double _percentValue;
  int _overallAnswerValue;

  Question(this.qid, this.question, this.answers, this.counterAnswer, this.creatorUsername, [this.status = 'Wird geprüft', this.voting = 0]);

  /// Berechnet Prozentwert für übergebene Antwort.
  /// multiply = false : 0.58 (Default)
  /// multiply = true  : 0.58 wird mit 100 multipliziert => 58.
  /// return z.B. 0.58 oder 58.
  double calculatePercentValue(int answer, [bool multiply = false]) {
    _percentValue = 0.0;
    if (counterAnswer[answer] == 0) {
      return _percentValue;
    }
    _percentValue = counterAnswer[answer] / _overallAnswerValue;
    if (multiply) {
      _percentValue *= 100;
    }
    return _percentValue;
  }

  /// Berechnet die Gesamtanzahl an Antworten für eine Frage.
  int calculateOverallAnswerValue(List<int> counterAnswer) {
    _overallAnswerValue = 0;
    for (int i = 0; i < counterAnswer.length; i++) {
      _overallAnswerValue += counterAnswer[i];
    }
    return _overallAnswerValue;
  }
}