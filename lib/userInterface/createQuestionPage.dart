import 'package:flutter/material.dart';
import 'package:opinion_app/util/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/util/systemSettings.dart';
import 'package:opinion_app/userInterface/opinionPage.dart';

class CreateQuestionPage extends StatefulWidget {
  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final GlobalKey<FormState> _addQuestionFormKey = GlobalKey<FormState>();
  final TextEditingController _question = TextEditingController();
  List<TextEditingController> _answers = List.generate(4, (i) => TextEditingController());
  String _selectedDurationInDays;

  @override
  void dispose() {
    _question.dispose();
    _answers.forEach((_answers) => _answers.dispose());
    super.dispose();
  }

  @override
  void initState() {
    _selectedDurationInDays = '1';
    SystemSettings.allowOnlyPortraitOrientation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frage erstellen',
          style: GoogleFonts.cormorantGaramond(
            textStyle: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _showCancelAlertDialog(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              margin: EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 20.0),
              elevation: 8.0,
              child: Center(
                child: Form(
                  key: _addQuestionFormKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 24.0, 30.0, 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          style: GoogleFonts.cormorantGaramond(
                            textStyle: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Fragetext',
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          controller: _question,
                          validator: _validateQuestion,
                          maxLength: 100,
                        ),
                        _answerTextFormField(_answers[0], 'Antwort 1'),
                        _answerTextFormField(_answers[1], 'Antwort 2'),
                        _optionalAnswerTextFormField(_answers[2], 'Antwort 3'),
                        _optionalAnswerTextFormField(_answers[3], 'Antwort 4'),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text('Dauer: ', style: TextStyle(fontSize: 20.0, color: Colors.grey.shade600)),
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
                                  child: Text(durationInDays, style: TextStyle(fontSize: 20.0)),
                                );
                              }).toList(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(_selectedDurationInDays == '1' ? ' Tag' : ' Tage',
                                  style: TextStyle(fontSize: 20.0, color: Colors.grey.shade600)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
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
                              child: Builder(
                                builder: (BuildContext context) {
                                  return FlatButton(
                                    child: Text(
                                      'Erstellen',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () => _createQuestionInCloudFirestore(context),
                                  );
                                },
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

  /// ////////////////////////////////////////
  ///     Antwort Eingabefelder
  /// ////////////////////////////////////////

  Widget _answerTextFormField(TextEditingController answer, String answerHintText) => TextFormField(
        style: GoogleFonts.cormorantGaramond(
          textStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        decoration: InputDecoration(
          hintText: answerHintText,
          errorMaxLines: 2,
        ),
        controller: answer,
        validator: _validateAnswers,
        maxLength: 40,
      );

  Widget _optionalAnswerTextFormField(TextEditingController answer, String answerHintText) => TextFormField(
        style: GoogleFonts.cormorantGaramond(
          textStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        decoration: InputDecoration(
          hintText: answerHintText + ' (optional)',
          errorMaxLines: 2,
        ),
        controller: answer,
        validator: _validateOptionalAnswers,
        maxLength: 40,
      );

  String _validateAnswers(String answer) {
    if (_answers[0].text.trim().isEmpty || _answers[1].text.trim().isEmpty) {
      return 'Bitte geben sie mindestens zwei Antworten ein.';
    }
    return null;
  }

  String _validateOptionalAnswers(String answer) {
    if (_answers[2].text.trim().isEmpty && _answers[3].text.trim().isNotEmpty) {
      return 'Bitte geben sie Antwort 3 ein oder entfernen sie Antwort 4.';
    }
    return null;
  }

  /// ////////////////////////////////////////
  ///         Neue Frage erstellen
  /// ////////////////////////////////////////

  void _createQuestionInCloudFirestore(BuildContext context) {
    try {
      if (_addQuestionFormKey.currentState.validate()) {
        List<String> answers = List<String>();
        List<int> counterAnswers = List<int>();
        for (int i = 0; i < _answers.length; i++) {
          if (_answers[i].text.isEmpty) {
            break;
          } else {
            answers.add(_answers[i].text);
            counterAnswers.add(0);
          }
        }
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
        _showSuccessAlertDialog(context);
      }
    } catch (error) {
      print('CREATE QUESTION ERROR: ' + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Frage konnte nicht erstellt werden. Bitte versuche es erneut.'),
      ));
    }
  }

  /// ////////////////////////////////////////
  ///         Zusätzliche Dialoge
  /// ////////////////////////////////////////

  _showSuccessAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Frage erfolgreich erstellt'),
          content: Text('Deine Frage wurde erfolgreich erstellt wir prüfen diese so schnell wie möglich.'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(color: primaryBlue),
              ),
              onPressed: () => setState(
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OpinionPage()));
                },
              ),
            ),
          ],
          elevation: 24.0,
        );
      },
    );
  }

  _showCancelAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Frage erstellen abbrechen?'),
          content: Text('Wollen sie die Frage verwerfen? Alle Änderungen gehen verloren.'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Ja',
                style: TextStyle(color: primaryBlue),
              ),
              onPressed: () => setState(
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OpinionPage()));
                },
              ),
            ),
            FlatButton(
              child: Text(
                'Nein',
                style: TextStyle(color: primaryBlue),
              ),
              onPressed: () => setState(
                () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
          elevation: 24.0,
        );
      },
    );
  }
}
