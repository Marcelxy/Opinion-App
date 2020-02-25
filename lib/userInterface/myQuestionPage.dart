import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:opinion_app/models/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/userInterface/opinionPage.dart';

class MyQuestionPage extends StatefulWidget {
  @override
  _MyQuestionPageState createState() => _MyQuestionPageState();
}

class _MyQuestionPageState extends State<MyQuestionPage> {
  final _addQuestionFormKey = GlobalKey<FormState>();
  final _question = TextEditingController();
  final _answer1 = TextEditingController();
  final _answer2 = TextEditingController();
  final Duration animationDuration = Duration(milliseconds: 400);
  final Duration delay = Duration(milliseconds: 300);
  GlobalKey rectGetterKey = RectGetter.createGlobalKey();
  Rect rect;
  FirebaseUser user;
  FixedExtentScrollController fixedExtentScrollController = new FixedExtentScrollController();
  List<Question> ownQuestionList = [];
  double percentValue;

  @override
  void dispose() {
    _question.dispose();
    _answer1.dispose();
    _answer2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          body: FutureBuilder(
              future: _loadOwnQuestionData(),
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return Center(child: CircularProgressIndicator());
                }
                return Container(
                  color: Colors.white,
                  child: ListWheelScrollView(
                      itemExtent: 300,
                      diameterRatio: 3.0,
                      children: <Widget>[
                        // ignore: sdk_version_ui_as_code
                        ...ownQuestionList.map((Question question) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade600, Color.fromRGBO(143, 148, 251, 1)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: EdgeInsets.all(25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(question.question, style: TextStyle(color: Colors.white70)),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.thumbs_up_down,
                                      color: Colors.white70,
                                      size: 22.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(question.voting.toString(), style: TextStyle(color: Colors.white70)),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                      _calculateOverallAnswerValue(question.counterAnswer1, question.counterAnswer2)
                                              .toString() +
                                          ' Antworten insgesamt',
                                      style: TextStyle(color: Colors.white70)),
                                ),
                                Text(question.counterAnswer1.toString(), style: TextStyle(color: Colors.white70)),
                                Text(percentValue.toString(), style: TextStyle(color: Colors.white70)),
                                Text(question.counterAnswer2.toString(), style: TextStyle(color: Colors.white70)),
                                Text(percentValue.toString(), style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          );
                        })
                      ]),
                );
              }),
          floatingActionButton: RectGetter(
            key: rectGetterKey,
            child: FloatingActionButton(
              onPressed: () => _showAddQuestionPage(),
              child: Icon(Icons.add),
              backgroundColor: Color.fromRGBO(143, 148, 251, 1),
            ),
          ),
        ),
        _ripple(),
      ],
    );
  }

  Widget _ripple() {
    if (rect == null) {
      return Container();
    }
    return Stack(
      children: <Widget>[
        AnimatedPositioned(
          duration: animationDuration,
          left: rect.left,
          right: MediaQuery.of(context).size.width - rect.right,
          top: rect.top,
          bottom: MediaQuery.of(context).size.height - rect.bottom,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
          ),
        ),
        Center(
          child: Form(
            key: _addQuestionFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Fragetext',
                  ),
                  controller: _question,
                  validator: _validateQuestion,
                  maxLength: 150,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Antwort 1',
                  ),
                  controller: _answer1,
                  validator: _validateAnswers,
                  maxLength: 50,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Antwort 2',
                  ),
                  controller: _answer2,
                  validator: _validateAnswers,
                  maxLength: 50,
                ),
                FlatButton(
                  child: Text('Erstellen'),
                  onPressed: () => _createQuestionInCloudFirestore(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _validateQuestion(String question) {
    int minLength = 5;
    if (question.trim().isEmpty) {
      return 'Bitte geben sie eine Frage ein.';
    } else if (question.length < minLength) {
      return 'Eine Frage muss mindestens $minLength Zeichen lang sein.';
    } else {
      return null;
    }
  }

  String _validateAnswers(String answer) {
    if (answer.trim().isEmpty) {
      return 'Bitte geben sie eine Antwort ein.';
    } else {
      return null;
    }
  }

  void _showAddQuestionPage() {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => rect = rect.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay);
    });
  }

  void _createQuestionInCloudFirestore() {
    try {
      if (_addQuestionFormKey.currentState.validate()) {
        Firestore.instance.collection('questions').getDocuments().then((myDocuments) async {
          user = await FirebaseAuth.instance.currentUser();
          // TODO ID kann theoetisch mehrmals vergeben werden bei sehr vielen gleichzeitigen Zugriffen. => Verbesserungspotenzial
          int qid = myDocuments.documents.length;
          Firestore.instance.collection('questions').document(qid.toString()).setData({
            'question': _question.text,
            'answer1': _answer1.text,
            'answer2': _answer2.text,
            'counterAnswer1': 0,
            'counterAnswer2': 0,
            'voting': 0,
          });
          Firestore.instance.collection('users').document(user.uid).updateData({
            'ownQuestions': FieldValue.arrayUnion([qid.toString()])
          });
        });
        setState(() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => OpinionPage()));
        });
        // TODO Snackbar anzeigen lassen das Frage erfolgreich erstellt wurde.
      }
    } catch (error) {
      print('CREATE QUESTION ERROR: ' + error);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage konnte nicht erstellt werden. Bitte erneut versuchen.'),
      ));
    }
  }

  Future<List<Question>> _loadOwnQuestionData() async {
    user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userInfo = await Firestore.instance.collection('users').document(user.uid).get();
    ownQuestionList.clear();
    for (int i = 0; i < userInfo.data['ownQuestions'].length; i++) {
      DocumentSnapshot questionData =
          await Firestore.instance.collection('questions').document(userInfo.data['ownQuestions'][i]).get();
      Question question = new Question(
          questionData.data['question'],
          questionData.data['answer1'],
          questionData.data['answer2'],
          questionData.data['counterAnswer1'],
          questionData.data['counterAnswer2'],
          questionData.data['voting']);
      ownQuestionList.add(question);
    }
    return ownQuestionList;
  }

  int _calculateOverallAnswerValue(int counterAnswer1, int counterAnswer2) {
    return counterAnswer1 + counterAnswer2;
  }

  double _calculatePercentValue(int answer, int counterAnswer1, int counterAnswer2) {
    percentValue = 0.0;
    if (counterAnswer1 == 0 && counterAnswer2 == 0) {
      return percentValue;
    }
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
}
