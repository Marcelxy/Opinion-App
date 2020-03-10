class User {
  String email;
  int level;
  int xp;
  List<String> questionRepository;
  List<String> releasedQuestions;
  List<String> notReleasedQuestions;
  List<String> completedQuestions;

  User(this.email, this.level, this.xp);

}