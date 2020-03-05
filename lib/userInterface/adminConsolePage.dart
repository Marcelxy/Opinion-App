import 'package:flutter/material.dart';
import 'package:opinion_app/models/question.dart';
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
        future: Firestore.instance.collection('questions').getDocuments(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          var documents = snapshot.data.documents;
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return ListView.builder(
                itemCount: documents.length,
                padding: const EdgeInsets.only(top: 20.0),
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Text(documents.elementAt(index).data['question'], textAlign: TextAlign.center),
                        Text(documents.elementAt(index).data['answers'][0]),
                        Text(documents.elementAt(index).data['answers'][1]),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              child: RaisedButton(
                                onPressed: () => _questionAccepted(),
                                child: Text('Akzeptieren'),
                              ),
                            ),
                            RaisedButton(
                              onPressed: () => _questionReject(),
                              child: Text('Ablehnen'),
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

  void _questionAccepted() {
    // TODO
  }

  void _questionReject() {
    // TODO
  }
}
