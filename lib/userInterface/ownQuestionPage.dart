import 'package:flutter/material.dart';
import 'package:opinion_app/util/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opinion_app/models/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/util/systemSettings.dart';
import 'package:opinion_app/widgets/percentProgressBar.dart';
import 'package:opinion_app/userInterface/createQuestionPage.dart';

class OwnQuestionPage extends StatefulWidget {
  @override
  _OwnQuestionPageState createState() => _OwnQuestionPageState();
}

class _OwnQuestionPageState extends State<OwnQuestionPage> {
  List<Question> _ownQuestionList = [];
  List<String> _status;
  int _value;

  @override
  void initState() {
    _value = 0;
    _status = [
      'Wird geprüft',
      'Freigegeben',
      'Nicht freigegeben',
      'Beendet',
    ];
    SystemSettings.allowOnlyPortraitOrientation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 36.0, 6.0, 8.0),
          child: Container(
            height: (MediaQuery.of(context).size.height / 100) * 7,
            color: secondaryBackgroundWhite,
            child: Wrap(
              spacing: 5.0,
              runSpacing: 3.0,
              children: <Widget>[
                _statusBar(),
              ],
            ),
          ),
        ),
        Container(
          height: (MediaQuery.of(context).size.height / 100) * 75,
          child: Scaffold(
            body: FutureBuilder(
                future: _loadOwnQuestionData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState == ConnectionState.done && _ownQuestionList.isNotEmpty) {
                    return _ownQuestions();
                  } else if (snapshot.connectionState == ConnectionState.done && _ownQuestionList.isEmpty) {
                    return _noneQuestionData();
                  }
                  return Center(child: CircularProgressIndicator());
                }),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _toPage(context),
              child: Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }

  /// ////////////////////////////////////////
  ///              Status Bar
  /// ////////////////////////////////////////

  Widget _statusBar() => Wrap(
        children: List<Widget>.generate(
          4,
          (int index) {
            return ChoiceChip(
              label: Text(
                _status[index],
                style: GoogleFonts.cormorantGaramond(
                  textStyle: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
              labelStyle: _value == index
                  ? TextStyle(color: textOnSecondaryWhite70, fontSize: 10.0, fontWeight: FontWeight.bold)
                  : TextStyle(color: Colors.blue.shade600, fontSize: 10.0, fontWeight: FontWeight.bold),
              selected: _value == index,
              backgroundColor: Color(0xffededed),
              onSelected: (bool selected) {
                setState(
                  () {
                    if (_value != index) {
                      _value = selected ? index : null;
                    }
                  },
                );
              },
              selectedColor: primaryBlue.withOpacity(0.6),
            );
          },
        ).toList(),
      );

  String _getQuestionCollection() {
    if (_value == 0) {
      return 'questionRepository';
    } else if (_value == 1) {
      return 'releasedQuestions';
    } else if (_value == 2) {
      return 'notReleasedQuestions';
    } else if (_value == 3) {
      return 'completedQuestions';
    }
    return '';
  }

  /// ////////////////////////////////////////
  ///          Eigene Fragenliste
  /// ////////////////////////////////////////

  Widget _ownQuestions() => Container(
        child: ListWheelScrollView(itemExtent: 470, diameterRatio: 6.0, children: <Widget>[
          ..._ownQuestionList.map((Question question) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, primaryBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Frage: ' + question.question, style: TextStyle(color: textOnSecondaryWhite, fontSize: 16.0)),
                  Divider(color: Colors.white),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.thumbs_up_down,
                        color: textOnSecondaryWhite70,
                        size: 22.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(question.voting.toString(), style: TextStyle(color: textOnSecondaryWhite70)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    child: Text(
                        question.calculateOverallAnswerValue(question.counterAnswer).toString() +
                            ' Antworten insgesamt',
                        style: TextStyle(color: textOnSecondaryWhite)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getResultList(question),
                  ),
                ],
              ),
            );
          }),
        ]),
      );

  List<Widget> getResultList(Question question) {
    var resultGroup = List<Widget>();
    for (int i = 0; i < question.answers.length; i++) {
      resultGroup.add(Text(question.answers[i], style: TextStyle(color: textOnSecondaryWhite)));
      resultGroup.add(PercentProgressBarWidget(
          percentValue: question.calculatePercentValue(i, false),
          percentTextValue: question.calculatePercentValue(i, true)));
    }
    return resultGroup;
  }

  Future<List<Question>> _loadOwnQuestionData() async {
    String collection = _getQuestionCollection();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userInfo = await Firestore.instance.collection('users').document(user.uid).get();
    _ownQuestionList.clear();
    for (int i = 0; i < userInfo.data[collection].length; i++) {
      DocumentSnapshot questionSnapshot =
          await Firestore.instance.collection(collection).document(userInfo.data[collection][i]).get();
      List<String> answers = List.from(questionSnapshot['answers']);
      List<int> counterAnswers = List.from(questionSnapshot['counterAnswers']);
      Question question = new Question(
        questionSnapshot.data['qid'],
        questionSnapshot.data['question'],
        answers,
        counterAnswers,
        questionSnapshot.data['creatorUsername'],
        questionSnapshot.data['status'],
        questionSnapshot.data['voting'],
      );
      _ownQuestionList.add(question);
    }
    return _ownQuestionList;
  }

  void _toPage(BuildContext context) {
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateQuestionPage()));
    });
  }

  /// ////////////////////////////////////////
  ///     Aktuell keine Fragen vorhanden
  /// ////////////////////////////////////////

  Widget _noneQuestionData() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Bisher keine Daten vorhanden. Erstelle eine neue Frage.',
            style: TextStyle(
              fontSize: 20.0,
              color: Color.fromRGBO(143, 148, 251, 1),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}
