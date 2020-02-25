import 'package:flutter/material.dart';
import 'dart:math';
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
  double percentValue;
  DocumentSnapshot question;

  @override
  void initState() {
    _showResults = false;
    _loadNextQuestion = true;
    _isEvaluateButtonEnabled = true;
    _randomSelectedQuestion = 0;
    percentValue = 0.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 40.0),
          elevation: 8.0,
          child: Stack(
            children: <Widget>[
              Container(
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
                                      question.data['question'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20.0, color: Colors.white70),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('Bewerte diese Frage', style: TextStyle(color: Colors.white70)),
                                      IconButton(
                                        icon: Icon(Icons.thumb_up, color: Colors.white70),
                                        onPressed: () => _isEvaluateButtonEnabled ? _setVoting(true) : null,
                                      ),
                                      Text(_isEvaluateButtonEnabled ? '?' : question.data['voting'].toString(),
                                          style: TextStyle(color: Colors.white70)),
                                      IconButton(
                                        icon: Icon(Icons.thumb_down, color: Colors.white70),
                                        onPressed: () => _isEvaluateButtonEnabled ? _setVoting(false) : null,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 270.0,
                                    child: RaisedButton(
                                      onPressed: () => _incrementCounterAnswer(1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        question.data['answer1'],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 270.0,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(10.0),
                                      ),
                                      onPressed: () => _incrementCounterAnswer(2),
                                      child: Text(
                                        question.data['answer2'],
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
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20.0),
                                    child: Text(question.data['question'], textAlign: TextAlign.center),
                                  ),
                                  Text(question.data['answer1'].toString()),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 20.0),
                                    child: LinearPercentIndicator(
                                      width: 250.0,
                                      lineHeight: 14.0,
                                      percent: _calculatePercentValue(1),
                                      backgroundColor: Colors.grey,
                                      progressColor: Colors.white70,
                                      center: Text(
                                        _getPercentValue(),
                                        style: new TextStyle(fontSize: 12.0),
                                      ),
                                      animation: true,
                                      animationDuration: 1000,
                                    ),
                                  ),
                                  Text(question.data['answer2'].toString()),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 20.0),
                                    child: LinearPercentIndicator(
                                      width: 250.0,
                                      lineHeight: 14.0,
                                      percent: _calculatePercentValue(2),
                                      backgroundColor: Colors.grey,
                                      progressColor: Colors.white70,
                                      center: Text(
                                        _getPercentValue(),
                                        style: new TextStyle(fontSize: 12.0),
                                      ),
                                      animation: true,
                                      animationDuration: 1000,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 270.0,
                                    child: RaisedButton(
                                      onPressed: () => _setNextQuestion(),
                                      child: Text(
                                        'Weiter',
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
      ),
    );
  }

  Future<DocumentSnapshot> _loadQuestionData() async {
    try {
      if (_loadNextQuestion) {
        // TODO Perfektionieren kann theoretisch zu Fehlern führen.
        QuerySnapshot questions = await Firestore.instance.collection('questions').getDocuments();
        _showResults = false;
        _loadNextQuestion = false;
        _isEvaluateButtonEnabled = true;
        int qid = questions.documents.length;
        var random = new Random();
        _randomSelectedQuestion = random.nextInt(qid);
        question = await Firestore.instance.collection('questions').document(_randomSelectedQuestion.toString()).get();
      }
    } catch (error) {
      print('READ QUESTION ERROR: ' + error);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage konnte nicht geladen werden. Bitte erneut versuchen.'),
      ));
    }
    return question;
  }

  _setNextQuestion() {
    setState(() {
      _loadNextQuestion = true;
    });
  }

  void _incrementCounterAnswer(int answer) async {
    String updatedValue;
    if (answer == 1) {
      updatedValue = 'counterAnswer1';
    } else if (answer == 2) {
      updatedValue = 'counterAnswer2';
    }
    await Firestore.instance
        .collection('questions')
        .document(_randomSelectedQuestion.toString())
        .updateData({updatedValue: FieldValue.increment(1)});
    // TODO nochmaliges laden aller Fragedaten nur für einen Wert (countAnswer1 oder countAnswer2) nicht optimal => Verbesserungspotenzial!
    question = await Firestore.instance.collection('questions').document(_randomSelectedQuestion.toString()).get();
    setState(() {
      _showResults = true;
    });
  }

  /*
  Percent Value e.g. 0.58 stand for 58%.
  return e.g. 0.58
   */
  double _calculatePercentValue(int answer) {
    int counterAnswer1 = question.data['counterAnswer1'];
    int counterAnswer2 = question.data['counterAnswer2'];
    percentValue = 0.0;
    if (answer == 1) {
      percentValue = counterAnswer1 / (counterAnswer1 + counterAnswer2);
    } else if (answer == 2) {
      percentValue = counterAnswer2 / (counterAnswer1 + counterAnswer2);
    }
    return percentValue;
  }

  String _getPercentValue() {
    percentValue *= 100;
    return percentValue.toStringAsFixed(1) + '%';
  }

  Future<void> _setVoting(bool thumpUp) async {
    int voting = 0;
    if (thumpUp) {
      voting = 1;
    } else {
      voting = -1;
    }
    await Firestore.instance
        .collection('questions')
        .document(_randomSelectedQuestion.toString())
        .updateData({'voting': FieldValue.increment(voting)});
    // TODO nochmaliges laden aller Fragedaten nur für einen Wert (voting) nicht optimal => Verbesserungspotenzial!
    question = await Firestore.instance.collection('questions').document(_randomSelectedQuestion.toString()).get();
    setState(() {
      _isEvaluateButtonEnabled = false;
    });
  }
}