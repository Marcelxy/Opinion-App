import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/util/systemSettings.dart';

class AdminConsolePage extends StatefulWidget {
  @override
  _AdminConsolePageState createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage> {
  @override
  void initState() {
    SystemSettings.allowOnlyPortraitOrientation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<QuerySnapshot>(
        future: Firestore.instance.collection('questionRepository').getDocuments(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              var questions = snapshot.data.documents;
              return ListView.builder(
                itemCount: questions.length,
                padding: const EdgeInsets.only(top: 20.0),
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text('Qid: ${questions.elementAt(index).data['qid']}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text('Frage: ${questions.elementAt(index).data['question']}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text('Antwort 1: ${questions.elementAt(index).data['answers'][0]}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text('Antwort 2: ${questions.elementAt(index).data['answers'][1]}'),
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Builder(builder: (BuildContext context) {
                                  return RaisedButton(
                                    onPressed: () => _releaseQuestion(
                                        true, questions.elementAt(index).data['qid'].toString(), context),
                                    child: Text('Freigeben'),
                                  );
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: RaisedButton(
                                  onPressed: () =>
                                      _releaseQuestion(false, questions.elementAt(index).data['qid'].toString(), context),
                                  child: Text('Nicht freigeben'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }

  Future<void> _releaseQuestion(bool release, String qid, BuildContext context) async {
    String status;
    String nextStatus;
    int durationInDays;
    status = release ? 'Freigegeben' : 'Nicht freigegeben';
    nextStatus = release ? 'releasedQuestions' : 'notReleasedQuestions';
    try {
      DocumentSnapshot question = await Firestore.instance.collection('questionRepository').document(qid).get();
      await Firestore.instance.collection(nextStatus).getDocuments().then((myDocuments) async {
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        DocumentSnapshot _user = await Firestore.instance.collection('users').document(user.uid).get();
        List<String> answers = List.from(question['answers']);
        List<int> counterAnswers = List.from(question['counterAnswers']);
        if (release) {
          durationInDays = question.data['durationInDays'];
        } else {
          durationInDays = 15;
        }
        await Firestore.instance.collection(nextStatus).document(qid).setData({
          'qid': qid,
          'question': question.data['question'],
          'voting': question.data['voting'],
          'status': status,
          'creatorId': user.uid,
          'creatorUsername': _user.data['username'],
          'answers': FieldValue.arrayUnion(answers),
          'counterAnswers': counterAnswers,
          'created': FieldValue.serverTimestamp(),
          'durationInDays': durationInDays,
        });
        await Firestore.instance.collection('users').document(user.uid).updateData({
          nextStatus: FieldValue.arrayUnion([qid]),
        });
        await Firestore.instance.collection('users').document(user.uid).updateData({
          'questionRepository': FieldValue.arrayRemove([qid]),
        });
        if (release) {
          await Firestore.instance.collection('users').document(user.uid).updateData({'xp': _user.data['xp'] + 25});
        }
        await Firestore.instance.collection('questionRepository').document(qid.toString()).delete();
        setState(() {});
      });
    } catch (error) {
      print('RELEASE QUESTION ERROR: ' + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Frage konnte nicht in collection ' + nextStatus + ' kopiert werden.'),
      ));
    }
  }
}
