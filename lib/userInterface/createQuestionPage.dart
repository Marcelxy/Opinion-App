import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/helper/systemSettings.dart';
import 'package:opinion_app/userInterface/opinionPage.dart';

class CreateQuestionPage extends StatefulWidget {
  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _addQuestionFormKey = GlobalKey<FormState>();
  final _question = TextEditingController();
  final _answer1 = TextEditingController();
  final _answer2 = TextEditingController();
  String _selectedDurationInDays = '1';

  @override
  void dispose() {
    _question.dispose();
    _answer1.dispose();
    _answer2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SystemSettings.allowOnlyPortraitOrientation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(143, 148, 251, 0.9),
        title: Text('Frage erstellen'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              margin: EdgeInsets.fromLTRB(20.0, 48.0, 20.0, 20.0),
              elevation: 8.0,
              child: Center(
                child: Form(
                  key: _addQuestionFormKey,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Fragetext',
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          controller: _question,
                          validator: _validateQuestion,
                          maxLength: 100,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Antwort 1',
                          ),
                          controller: _answer1,
                          validator: _validateAnswers,
                          maxLength: 40,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Antwort 2',
                          ),
                          controller: _answer2,
                          validator: _validateAnswers,
                          maxLength: 40,
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text('Dauer: ', style: TextStyle(fontSize: 16.0)),
                            ),
                            DropdownButton<String>(
                              value: _selectedDurationInDays,
                              icon: Icon(Icons.arrow_downward, color: Color.fromRGBO(143, 148, 251, 0.9)),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Color.fromRGBO(143, 148, 251, 0.9)),
                              underline: Container(
                                height: 2,
                                color: Color.fromRGBO(143, 148, 251, 0.9),
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  _selectedDurationInDays = newValue;
                                });
                              },
                              items: <String>['1', '2', '3', '4', '5', '6', '7']
                                  .map<DropdownMenuItem<String>>((String durationInDays) {
                                return DropdownMenuItem<String>(
                                  value: durationInDays,
                                  child: Text(durationInDays, style: TextStyle(fontSize: 16.0)),
                                );
                              }).toList(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(_selectedDurationInDays == '1' ? ' Tag' : ' Tage', style: TextStyle(fontSize: 16.0)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(143, 148, 251, 1),
                                  Color.fromRGBO(143, 148, 251, 0.6),
                                ],
                              ),
                            ),
                            child: ButtonTheme(
                              height: 50,
                              minWidth: 300,
                              child: FlatButton(
                                child: Text(
                                  'Erstellen',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _createQuestionInCloudFirestore(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    } else if (_answer1.text.toString().trim().compareTo(_answer2.text.toString().trim()) == 0) {
      return 'Antworten müssen unterschiedlich sein.';
    } else {
      return null;
    }
  }

  void _createQuestionInCloudFirestore() {
    try {
      if (_addQuestionFormKey.currentState.validate()) {
        List<String> answers = List<String>();
        answers.add(_answer1.text);
        answers.add(_answer2.text);
        List<int> counterAnswers = List<int>();
        counterAnswers.add(0);
        counterAnswers.add(0);

        Firestore.instance.collection('questionRepository').getDocuments().then((myDocuments) async {
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          DocumentSnapshot userData = await Firestore.instance.collection('users').document(user.uid).get();
          String autoGeneratedId = Firestore.instance.collection('questionRepository').document().documentID;
          Firestore.instance.collection('questionRepository').document(autoGeneratedId).setData({
            'qid': autoGeneratedId,
            'question': _question.text,
            'voting': 0,
            'status': 'Wird geprüft',
            'creatorId': user.uid,
            'creatorUsername': userData.data['username'],
            'answers': FieldValue.arrayUnion(answers),
            'counterAnswers': counterAnswers,
            'durationInDays': int.parse(_selectedDurationInDays),
          });
          Firestore.instance.collection('users').document(user.uid).updateData({
            'questionRepository': FieldValue.arrayUnion([autoGeneratedId])
          });
        });
        setState(() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => OpinionPage()));
        });
        // TODO Nachricht eventuell Snackbar anzeigen lassen das Frage erfolgreich erstellt wurde.
      }
    } catch (error) {
      print('CREATE QUESTION ERROR: ' + error);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage konnte nicht erstellt werden. Bitte erneut versuchen.'),
      ));
    }
  }
}
