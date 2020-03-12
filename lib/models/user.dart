class User {
  String username;
  String email;
  int xp;
  List<String> questionRepository;
  List<String> releasedQuestions;
  List<String> notReleasedQuestions;
  List<String> completedQuestions;

  User(this.email, this.username, this.xp);

}