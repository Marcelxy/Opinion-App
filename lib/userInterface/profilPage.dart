import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/helper/systemSettings.dart';
import 'package:opinion_app/userInterface/loginPage.dart';
import 'package:opinion_app/userInterface/adminConsolePage.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  DocumentSnapshot user;

  @override
  void initState() {
    SystemSettings.allowOnlyPortraitOrientation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(143, 148, 251, 0.9),
        title: Text('Profil'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _signOut(),
            color: Colors.white,
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FutureBuilder(
                  future: _loadUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(user.data['email']),
                          Text('Benutzername: ' + user.data['username']),
                          Text('Erfahrungspunkte: ' + user.data['xp'].toString()),
                          Visibility(
                            visible: _isAdmin(),
                            child: RaisedButton(
                              onPressed: () => _toPage(context),
                              child: Text(
                                'Admin Konsole',
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DocumentSnapshot> _loadUserData() async {
    firebaseUser = await _auth.currentUser();
    user = await Firestore.instance.collection('users').document(firebaseUser.uid).get();
    return user;
  }

  bool _isAdmin() {
    if (firebaseUser.email == "marcel.geirhos@gmail.com") {
      return true;
    }
    return false;
  }

  void _signOut() async {
    await _auth.signOut();
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  void _toPage(BuildContext context) {
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminConsolePage()));
    });
  }
}