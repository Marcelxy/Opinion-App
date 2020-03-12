import 'package:flutter/material.dart';
import 'dart:math';
import 'package:opinion_app/models/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot user;
  DocumentSnapshot questionSnapshot;
  List<int> counterAnswers;
  Question question;

  @override
  void initState() {
    _showResults = false;
    _loadNextQuestion = true;
    _isEvaluateButtonEnabled = true;
    _randomSelectedQuestion = 0;
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
                      return CircularProgressIndicator();
                    } else if (snapshot.connectionState == ConnectionState.done) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              user.data['username'],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Erfahrungspunkte: ' + user.data['xp'].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ],
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
                            } else {
                              if (_showResults == false) {
                                return Visibility(
                                  visible: _showResults ? false : true,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 24.0),
                                        child: Text(
                                          question.question,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 24.0, color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text('Bewerte diese Frage', style: TextStyle(color: Colors.white70)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 50.0),
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
                                            onPressed: () => _incrementCounterAnswer(1),
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
                                            onPressed: () => _incrementCounterAnswer(2),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 30.0),
                                          child: Text(question.question,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 24.0, color: Colors.white)),
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
                            }
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
    FirebaseUser currentUser = await _auth.currentUser();
    user = await Firestore.instance.collection('users').document(currentUser.uid).get();
    return user;
  }

  Future<DocumentSnapshot> _loadQuestionData() async {
    try {
      if (_loadNextQuestion) {
        QuerySnapshot questions = await Firestore.instance.collection('releasedQuestions').getDocuments();
        _showResults = false;
        _loadNextQuestion = false;
        _isEvaluateButtonEnabled = true;
        int qid = questions.documents.length;
        var random = new Random();
        _randomSelectedQuestion = random.nextInt(qid);
        questionSnapshot =
            await Firestore.instance.collection('releasedQuestions').document(_randomSelectedQuestion.toString()).get();
        List<String> answers = List.from(questionSnapshot.data['answers']);
        counterAnswers = List.from(questionSnapshot.data['counterAnswers']);
        question = new Question(
          questionSnapshot.data['question'],
          answers,
          counterAnswers,
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

  Future<void> _incrementCounterAnswer(int answer) async {
    if (answer == 1) {
      question.counterAnswer[0]++;
    } else if (answer == 2) {
      question.counterAnswer[1]++;
    }
    Firestore.instance.collection('releasedQuestions').document(_randomSelectedQuestion.toString()).updateData({
      'counterAnswers': counterAnswers,
    });
    questionSnapshot =
        await Firestore.instance.collection('releasedQuestions').document(_randomSelectedQuestion.toString()).get();
    setState(() {
      _showResults = true;
    });
  }

  Future<void> _setVoting(bool thumpUp) async {
    thumpUp ? question.voting++ : question.voting--;
    await Firestore.instance
        .collection('releasedQuestions')
        .document(_randomSelectedQuestion.toString())
        .updateData({'voting': question.voting});
    questionSnapshot =
        await Firestore.instance.collection('releasedQuestions').document(_randomSelectedQuestion.toString()).get();
    setState(() {
      _isEvaluateButtonEnabled = false;
    });
  }
}
