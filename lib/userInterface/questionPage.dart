import 'package:flutter/material.dart';
import 'dart:math';
import 'package:opinion_app/util/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opinion_app/models/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:opinion_app/widgets/creator.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/util/systemSettings.dart';
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
  FirebaseUser _firebaseUser;

  DocumentSnapshot _userSnapshot;
  DocumentSnapshot _questionSnapshot;
  QuerySnapshot _questionList;
  List<int> _counterAnswers;
  Question _question;

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
            _userCard(),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              elevation: 8.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: (MediaQuery.of(context).size.height / 100) * 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade800, primaryBlue],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: FutureBuilder(
                          future: _loadQuestionData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.none ||
                                snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.connectionState == ConnectionState.done &&
                                _questionList.documents.isNotEmpty) {
                              if (_showResults == false) {
                                return _questionSite();
                              } else {
                                return _resultSite();
                              }
                            } else if (snapshot.connectionState == ConnectionState.done &&
                                _questionList.documents.isEmpty) {
                              return _noQuestionsText();
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

  /// ////////////////////////////////////////
  ///    Benutzername und Erfahrungspunkte
  /// ////////////////////////////////////////

  Widget _userCard() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        margin: const EdgeInsets.fromLTRB(0.0, 48.0, 0.0, 20.0),
        elevation: 8.0,
        child: FutureBuilder(
          future: _loadUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return _userData('             ', 0);
            } else if (snapshot.connectionState == ConnectionState.done) {
              return _userData(_userSnapshot.data['username'], _userSnapshot.data['xp']);
            }
            return _userData(_userSnapshot.data['username'], _userSnapshot.data['xp']);
          },
        ),
      );

  Widget _userData(String username, int xp) => FittedBox(
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Icon(Icons.person),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 32.0, top: 14.0, bottom: 14.0),
          child: Text(
            username,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: Icon(Icons.new_releases),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Text(
            'Erfahrungspunkte: ' + xp.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    ),
  );

  Future<DocumentSnapshot> _loadUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    _firebaseUser = await auth.currentUser();
    _userSnapshot = await Firestore.instance.collection('users').document(_firebaseUser.uid).get();
    return _userSnapshot;
  }

  /// ////////////////////////////////////////
  ///      Frage Seite mit Antworten
  /// ////////////////////////////////////////

  Widget _questionSite() => Visibility(
        visible: _showResults ? false : true,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  child: Text(
                    _question?.creatorUsername[0] ?? '',
                    style: GoogleFonts.cormorantGaramond(
                      textStyle: TextStyle(
                        fontSize: 19.0,
                      ),
                    ),
                  ),
                ),
                Creator(creatorUsername: _question?.creatorUsername ?? ''),
                Padding(
                  padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width / 100) * 7),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () => _setNextQuestion(),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.white),
            _questionText(0.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: <Widget>[
                  Text('Bewerte diese Frage', style: TextStyle(color: textOnSecondaryWhite70)),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: IconButton(
                      icon: Icon(Icons.thumb_up, color: textOnSecondaryWhite70),
                      onPressed: () => _isEvaluateButtonEnabled ? _setVoting(true) : null,
                    ),
                  ),
                  Text(_isEvaluateButtonEnabled ? '?' : _question.voting.toString(),
                      style: TextStyle(color: textOnSecondaryWhite70, fontSize: 19.0)),
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: textOnSecondaryWhite70),
                    onPressed: () => _isEvaluateButtonEnabled ? _setVoting(false) : null,
                  ),
                ],
              ),
            ),
            for (int i = 0; i < _question.answers.length; i++) _answerButton(i),
          ],
        ),
      );

  Widget _questionText(double paddingLeft) => Padding(
        padding: EdgeInsets.fromLTRB(paddingLeft, 18.0, 0.0, 12.0),
        child: AutoSizeText(
          _question.question,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(textStyle: TextStyle(fontSize: 22.0, color: textOnSecondaryWhite)),
          minFontSize: 12.0,
          maxLines: 5,
        ),
      );

  Widget _answerButton(int answer) => Padding(
        padding: const EdgeInsets.only(top: 14.0),
        child: SizedBox(
          width: (MediaQuery.of(context).size.width / 100) * 80,
          height: 36.0,
          child: RaisedButton(
            onPressed: () => _showQuestionResults(answer),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
            ),
            child: AutoSizeText(
              _question.answers[answer],
              minFontSize: 12.0,
              maxLines: 1,
            ),
            color: textOnSecondaryWhite,
          ),
        ),
      );

  Future<DocumentSnapshot> _loadQuestionData() async {
    if (_loadNextQuestion) {
      var random = new Random();
      _showResults = false;
      _loadNextQuestion = false;
      _isEvaluateButtonEnabled = true;
      try {
        _questionList = await Firestore.instance.collection('releasedQuestions').getDocuments();
        _randomSelectedQuestion = random.nextInt(_questionList.documents.length);
        _questionSnapshot = await Firestore.instance
            .collection('releasedQuestions')
            .document(_questionList.documents[_randomSelectedQuestion].documentID)
            .get();
        List<String> answers = List.from(_questionSnapshot.data['answers']);
        _counterAnswers = List.from(_questionSnapshot.data['counterAnswers']);
        _question = new Question(
          _questionSnapshot.data['qid'],
          _questionSnapshot.data['question'],
          answers,
          _counterAnswers,
          _questionSnapshot.data['creatorUsername'],
          _questionSnapshot.data['status'],
          _questionSnapshot.data['voting'],
        );
      } catch (error) {
        print('READ QUESTION ERROR: ' + error.toString());
      }
    }
    return _questionSnapshot;
  }

  _setVoting(bool thumpUp) async {
    try {
      _increaseUserXp(1);
      thumpUp ? _question.voting++ : _question.voting--;
      await Firestore.instance
          .collection('releasedQuestions')
          .document(_questionList.documents[_randomSelectedQuestion].documentID)
          .updateData({'voting': _question.voting});
      setState(() {
        _isEvaluateButtonEnabled = false;
      });
    } catch (error) {
      print('SET VOTING ERROR: ' + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage Voting konnte nicht erhöht/erniedrigt werden. Bitte versuche es erneut.'),
      ));
    }
  }

  _increaseUserXp(int xp) async {
    try {
      await Firestore.instance
          .collection('users')
          .document(_firebaseUser.uid)
          .updateData({'xp': _userSnapshot.data['xp'] + xp});
    } catch (error) {
      print('INCREASE USER XP ERROR: ' + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Es konnten keine Erfahrungspunkte hinzugefügt werden.'),
      ));
    }
  }

  _setNextQuestion() {
    setState(() {
      _loadNextQuestion = true;
    });
  }

  /// ////////////////////////////////////////
  ///             Ergebnisseite
  /// ////////////////////////////////////////

  Widget _resultSite() => Visibility(
        visible: _showResults ? true : false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  child: Text(
                    _question?.creatorUsername[0] ?? '',
                    style: GoogleFonts.cormorantGaramond(
                      textStyle: TextStyle(
                        fontSize: 19.0,
                      ),
                    ),
                  ),
                ),
                Creator(creatorUsername: _question.creatorUsername),
              ],
            ),
            Divider(color: Colors.white),
            _questionText(16.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 18.0),
              child: Text(
                  _question.calculateOverallAnswerValue(_question.counterAnswer).toString() + ' Antworten insgesamt',
                  style: TextStyle(color: textOnSecondaryWhite)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getResultList(),
            ),
            _continueButton(),
          ],
        ),
      );

  List<Widget> getResultList() {
    var resultGroup = List<Widget>();
    for (int i = 0; i < _question.answers.length; i++) {
      resultGroup.add(_answerText(i));
      resultGroup.add(_answerPercentProgressBar(i));
    }
    return resultGroup;
  }

  Widget _answerText(int answer) => Padding(
        padding: const EdgeInsets.only(left: 18.0, bottom: 2.0),
        child: Text(_question.answers[answer], style: TextStyle(fontSize: 16.0, color: textOnSecondaryWhite)),
      );

  Widget _answerPercentProgressBar(int answer) => Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 6.0),
        child: LinearPercentIndicator(
          width: (MediaQuery.of(context).size.width / 100) * 70,
          lineHeight: 14.0,
          percent: _question.calculatePercentValue(answer),
          backgroundColor: Colors.transparent.withOpacity(0.25),
          progressColor: textOnSecondaryWhite,
          center: Text(
            _question.calculatePercentValue(answer, true).toStringAsFixed(1) + "%",
            style: new TextStyle(fontSize: 14.0, height: 0.7, fontWeight: FontWeight.w600),
          ),
          animation: true,
          animationDuration: 1000,
        ),
      );

  Widget _continueButton() => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            width: (MediaQuery.of(context).size.width / 100) * 70,
            height: 36.0,
            child: RaisedButton(
              onPressed: () => _setNextQuestion(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                'Weiter',
                style: TextStyle(fontSize: 22.0),
              ),
              color: textOnSecondaryWhite,
            ),
          ),
        ),
      );

  _showQuestionResults(int answer) async {
    try {
      _increaseUserXp(2);
      _question.counterAnswer[answer]++;
      await Firestore.instance
          .collection('releasedQuestions')
          .document(_questionList.documents[_randomSelectedQuestion].documentID)
          .updateData({
        'counterAnswers': _counterAnswers,
      });
      setState(() {
        _showResults = true;
      });
    } catch (error) {
      print('SHOW QUESTION RESULTS ERROR: ' + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage Ergebnisse konnten nicht geladen werden. Bitte versuche es erneut.'),
      ));
    }
  }

  /// ////////////////////////////////////////
  ///     Aktuell keine Fragen vorhanden
  /// ////////////////////////////////////////

  Widget _noQuestionsText() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Aktuell sind keine Fragen vorhanden. Erstell du eine neue Frage und lass sie von der Community beantworten.',
            style: TextStyle(
              fontSize: 20.0,
              color: textOnSecondaryWhite,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      );
}
