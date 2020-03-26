import 'package:flutter/material.dart';
import 'dart:math';
import 'package:opinion_app/models/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/helper/systemSettings.dart';
import 'package:opinion_app/widgets/creatorWidget.dart';
import 'package:percent_indicator/percent_indicator.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  bool _showResults;
  bool _loadNextQuestion;
  bool _isEvaluateButtonEnabled;
  int _randomSelectedQuestion;
  FirebaseUser firebaseUser;
  DocumentSnapshot userSnapshot;
  DocumentSnapshot questionSnapshot;
  List<int> counterAnswers;
  Question question;
  List<DocumentSnapshot> _questionList;

  @override
  void initState() {
    _showResults = false;
    _loadNextQuestion = true;
    _isEvaluateButtonEnabled = true;
    _randomSelectedQuestion = 0;
    SystemSettings.allowOnlyPortraitOrientation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              margin: EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 20.0),
              elevation: 8.0,
              child: FutureBuilder(
                  future: _loadUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState == ConnectionState.done) {
                      return FittedBox(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Icon(
                                Icons.person,
                                color: Colors.blue.shade600,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0, right: 32.0, top: 14.0, bottom: 14.0),
                              child: Text(
                                userSnapshot.data['username'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Icon(
                                Icons.new_releases,
                                color: Colors.blue.shade600,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Text(
                                'Erfahrungspunkte: ' + userSnapshot.data['xp'].toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return CircularProgressIndicator();
                  }),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              margin: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
              elevation: 8.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade800, Color.fromRGBO(143, 148, 251, 0.9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: FutureBuilder(
                          future: _loadQuestionData(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData == false) {
                              return CircularProgressIndicator();
                              // TODO
                            } else if (_questionList.isEmpty) {
                              return Text(
                                'Bisher keine Daten vorhanden. Erstelle eine neue Frage.',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              );
                            }
                            else if (snapshot.connectionState == ConnectionState.done && _questionList.isNotEmpty) {
                              if (_showResults == false) {
                                return Visibility(
                                  visible: _showResults ? false : true,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          CreatorWidget(creatorUsername: question.creatorUsername),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 75.0),
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_forward, color: Colors.white),
                                              onPressed: () => _setNextQuestion(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(color: Colors.white),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8.0, 70.0, 0.0, 24.0),
                                        child: AutoSizeText(
                                          question.question,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 24.0, color: Colors.white),
                                          minFontSize: 10.0,
                                          maxLines: 5,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text('Bewerte diese Frage', style: TextStyle(color: Colors.white70)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 40.0),
                                              child: IconButton(
                                                icon: Icon(Icons.thumb_up, color: Colors.white70),
                                                onPressed: () => _isEvaluateButtonEnabled ? _setVoting(true) : null,
                                              ),
                                            ),
                                            Text(_isEvaluateButtonEnabled ? '?' : question.voting.toString(),
                                                style: TextStyle(color: Colors.white70)),
                                            IconButton(
                                              icon: Icon(Icons.thumb_down, color: Colors.white70),
                                              onPressed: () => _isEvaluateButtonEnabled ? _setVoting(false) : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24.0),
                                        child: SizedBox(
                                          width: 270.0,
                                          height: 40.0,
                                          child: RaisedButton(
                                            onPressed: () => _showQuestionResults(1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(6.0),
                                            ),
                                            child: Text(
                                              question.answers[0],
                                            ),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24.0),
                                        child: SizedBox(
                                          width: 270.0,
                                          height: 40.0,
                                          child: RaisedButton(
                                            onPressed: () => _showQuestionResults(2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(6.0),
                                            ),
                                            child: Text(
                                              question.answers[1],
                                            ),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Visibility(
                                  visible: _showResults ? true : false,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      CreatorWidget(creatorUsername: question.creatorUsername),
                                      Divider(color: Colors.white),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16.0, 70.0, 0.0, 24.0),
                                        child: AutoSizeText(
                                          'Frage: ' + question.question,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontSize: 24.0, color: Colors.white),
                                          minFontSize: 10.0,
                                          maxLines: 5,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 14.0, left: 18.0),
                                        child: Text(
                                            question
                                                    .calculateOverallAnswerValue(
                                                        question.counterAnswer[0], question.counterAnswer[1])
                                                    .toString() +
                                                ' Antworten insgesamt',
                                            style: TextStyle(color: Colors.white)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 18.0, bottom: 2.0),
                                        child: Text(question.answers[0],
                                            style: TextStyle(fontSize: 16.0, color: Colors.white)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 20.0),
                                        child: LinearPercentIndicator(
                                          width: 250.0,
                                          lineHeight: 14.0,
                                          percent: question.calculatePercentValue(1),
                                          backgroundColor: Colors.transparent.withOpacity(0.25),
                                          progressColor: Colors.white,
                                          center: Text(
                                            question.calculatePercentValue(1, true).toStringAsFixed(1) + "%",
                                            style: new TextStyle(fontSize: 12.0),
                                          ),
                                          animation: true,
                                          animationDuration: 1000,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 18.0, bottom: 2.0),
                                        child: Text(question.answers[1],
                                            style: TextStyle(fontSize: 16.0, color: Colors.white)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 20.0),
                                        child: LinearPercentIndicator(
                                          width: 250.0,
                                          lineHeight: 14.0,
                                          percent: question.calculatePercentValue(2),
                                          backgroundColor: Colors.transparent.withOpacity(0.25),
                                          progressColor: Colors.white,
                                          center: Text(
                                            question.calculatePercentValue(2, true).toStringAsFixed(1) + "%",
                                            style: new TextStyle(fontSize: 12.0),
                                          ),
                                          animation: true,
                                          animationDuration: 1000,
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 24.0),
                                          child: SizedBox(
                                            width: 270.0,
                                            height: 40.0,
                                            child: RaisedButton(
                                              onPressed: () => _setNextQuestion(),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: new BorderRadius.circular(6.0),
                                              ),
                                              child: Text(
                                                'Weiter',
                                              ),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else if (snapshot.connectionState == ConnectionState.done && _questionList.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Text(
                                    'Aktuell sind keine Fragen vorhanden. Erstell du eine neue Frage und lass sie von der Community beantworten.',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DocumentSnapshot> _loadUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    firebaseUser = await auth.currentUser();
    userSnapshot = await Firestore.instance.collection('users').document(firebaseUser.uid).get();
    return userSnapshot;
  }

  Future<DocumentSnapshot> _loadQuestionData() async {
    try {
      if (_loadNextQuestion) {
        _showResults = false;
        _loadNextQuestion = false;
        _isEvaluateButtonEnabled = true;
        QuerySnapshot releasedQuestions = await Firestore.instance.collection('releasedQuestions').getDocuments();
        _questionList = releasedQuestions.documents;
        var random = new Random();
        _randomSelectedQuestion = random.nextInt(_questionList.length);
        questionSnapshot = await Firestore.instance
            .collection('releasedQuestions')
            .document(_questionList[_randomSelectedQuestion].documentID)
            .get();
        List<String> answers = List.from(questionSnapshot.data['answers']);
        counterAnswers = List.from(questionSnapshot.data['counterAnswers']);
        question = new Question(
          questionSnapshot.data['question'],
          answers,
          counterAnswers,
          questionSnapshot.data['creatorUsername'],
          questionSnapshot.data['status'],
          questionSnapshot.data['voting'],
        );
      }
    } catch (error) {
      print('READ QUESTION ERROR: ' + error);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage konnte nicht geladen werden. Bitte erneut versuchen.'),
      ));
    }
    return questionSnapshot;
  }

  _setNextQuestion() {
    setState(() {
      _loadNextQuestion = true;
    });
  }

  _showQuestionResults(int answer) async {
    try {
      _increaseUserXp(2);
      if (answer == 1) {
        question.counterAnswer[0]++;
      } else if (answer == 2) {
        question.counterAnswer[1]++;
      }
      Firestore.instance
          .collection('releasedQuestions')
          .document(_questionList[_randomSelectedQuestion].documentID)
          .updateData({
        'counterAnswers': counterAnswers,
      });
      questionSnapshot = await Firestore.instance
          .collection('releasedQuestions')
          .document(_questionList[_randomSelectedQuestion].documentID)
          .get();
      setState(() {
        _showResults = true;
      });
    } catch (error) {
      print('SHOW QUESTION RESULTS ERROR: ' + error);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage Ergebnisse konnten nicht geladen werden. Bitte erneut versuchen.'),
      ));
    }
  }

  _setVoting(bool thumpUp) async {
    try {
      _increaseUserXp(1);
      thumpUp ? question.voting++ : question.voting--;
      await Firestore.instance
          .collection('releasedQuestions')
          .document(_questionList[_randomSelectedQuestion].documentID)
          .updateData({'voting': question.voting});
      questionSnapshot = await Firestore.instance
          .collection('releasedQuestions')
          .document(_questionList[_randomSelectedQuestion].documentID)
          .get();
      setState(() {
        _isEvaluateButtonEnabled = false;
      });
    } catch (error) {
      print('SET VOTING ERROR: ' + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage Voting konnte nicht erhöht/erniedrigt werden. Bitte erneut versuchen.'),
      ));
    }
  }

  _increaseUserXp(int xp) async {
    await Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .updateData({'xp': userSnapshot.data['xp'] + xp});
  }
}
