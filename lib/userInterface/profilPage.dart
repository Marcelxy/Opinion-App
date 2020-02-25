import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/userInterface/loginPage.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Profil',
                style: TextStyle(fontSize: 22.0),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FutureBuilder(
                  future: _loadUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) {
                      return CircularProgressIndicator();
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(user.data['email']),
                        Text('Level: ' + user.data['level'].toString()),
                        Text('Erfahrungspunkte: ' + user.data['xp'].toString()),
                      ],
                    );
                  },
                ),
              ),
              RaisedButton(
                onPressed: () => _signOut(),
                child: Text(
                  'Ausloggen',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DocumentSnapshot> _loadUserData() async {
    FirebaseUser currentUser = await _auth.currentUser();
    user = await Firestore.instance.collection('users').document(currentUser.uid).get();
    return user;
  }

  void _signOut() async {
    await _auth.signOut();
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }
}
