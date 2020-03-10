import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminConsolePage extends StatefulWidget {
  @override
  _AdminConsolePageState createState() => _AdminConsolePageState();
}

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class _AdminConsolePageState extends State<AdminConsolePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<QuerySnapshot>(
        future: Firestore.instance.collection('questionRepository').getDocuments(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
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
                    child: Column(
                      children: <Widget>[
                        Text(questions.elementAt(index).data['question'], textAlign: TextAlign.center),
                        Text(questions.elementAt(index).data['answers'][0]),
                        Text(questions.elementAt(index).data['answers'][1]),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              child: RaisedButton(
                                onPressed: () => _releaseQuestion(true, questions.elementAt(index).data['qid']),
                                child: Text('Freigeben'),
                              ),
                            ),
                            RaisedButton(
                              onPressed: () => _releaseQuestion(false, questions.elementAt(index).data['qid']),
                              child: Text('Nicht freigeben'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }

  Future<void> _releaseQuestion(bool release, int qid) async {
    String status;
    String nextStatus;
    status = release ? 'Freigegeben' : 'Nicht freigegeben';
    nextStatus = release ? 'releasedQuestions' : 'notReleasedQuestions';
    try {
      DocumentSnapshot question = await Firestore.instance.collection('questionRepository').document(qid.toString()).get();
      await Firestore.instance.collection(nextStatus).getDocuments().then((myDocuments) async {
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        int lengthId = myDocuments.documents.length;
        List<String> answers = List.from(question['answers']);
        List<int> counterAnswers = List.from(question['counterAnswers']);
        await Firestore.instance.collection(nextStatus).document(lengthId.toString()).setData({
          'qid': lengthId,
          'question': question.data['question'],
          'voting': question.data['voting'],
          'status': status,
          'answers': FieldValue.arrayUnion(answers),
          'counterAnswers': counterAnswers,
        });
        Firestore.instance.collection('users').document(user.uid).updateData({
          nextStatus: FieldValue.arrayUnion([lengthId.toString()]),
        });
        Firestore.instance.collection('users').document(user.uid).updateData({
          'questionRepository': FieldValue.arrayRemove([qid.toString()]),
        });
        setState(() async {
          await Firestore.instance.collection('questionRepository').document(qid.toString()).delete();
        });
        // TODO Frageids werden doppelt vergeben müssen eindeutig sein.
        // TODO hier weitermachen Filter mit verschiedenen Fragestati implementieren und zuerst Status der Frage anzeigen lassen und Collections anlegen siehe _questionNotRelease in Collection notReleasedQuestions kopieren und von questionRepository entfernen.
      });
    } catch (error) {
      print('RELEASE QUESTION ERROR: ' + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Frage konnte nicht in collection ' + nextStatus + ' kopiert werden.'),
      ));
    }
  }
}
