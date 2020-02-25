class Question {
  final String question;
  final String answer1;
  final String answer2;
  final int counterAnswer1;
  final int counterAnswer2;
  final int voting;

  Question(this.question, this.answer1, this.answer2, this.counterAnswer1, this.counterAnswer2, this.voting);
}

class Answer {
  final String answer;
  final String counterAnswer;

  Answer(this.answer, this.counterAnswer);
}