import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:opinion_app/util/systemSettings.dart';
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
  StorageReference firebaseStorageRef;
  var imageURL;

  @override
  void initState() {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child(/*firebaseUser.uid +*/ 'HL2Af3a1jScG7X2jMv89jhRNePh2.jpg');
    imageURL = ref.getDownloadURL();
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
        leading: FutureBuilder(
            future: _loadUserData(),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return Text('');
              } else if (snapshot.connectionState == ConnectionState.done) {
                return Visibility(
                  visible: _isAdmin(),
                  child: IconButton(
                    icon: const Icon(Icons.public),
                    onPressed: () => _toPage(context),
                    color: Colors.white,
                  ),
                );
              }
              return Text('');
            }),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _signOut(),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(143, 148, 251, 0.9), Colors.blue.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(75.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
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
                              Center(
                                child: imageURL == null ? noUserImage() : displayUserImage(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  'E-Mail: ' + user.data['email'],
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  'Benutzername: ' + user.data['username'],
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  'Erfahrungspunkte: ' + user.data['xp'].toString(),
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
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
          Container(
            height: 300,
            child: StreamBuilder<QuerySnapshot>(
              stream: _loadHighscoreUser().snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.hasData == false) {
                  return CircularProgressIndicator();
                }
                return ListView(
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return ListTile(
                      leading: CircleAvatar(child: Text(document['username'][0])),
                      title: Text(document['username']),
                      trailing: Text(document['xp'].toString()),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget noUserImage() {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _saveUserImageInCloudStorage();
            },
            child: CircleAvatar(
              radius: 40.0,
              child: Text('+', style: TextStyle(fontSize: 40.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget displayUserImage() {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _saveUserImageInCloudStorage();
            },
            child: CircleAvatar(
              radius: 40.0,
              backgroundImage: NetworkImage(imageURL),
            ),
          ),
        ],
      ),
    );
  }

  _saveUserImageInCloudStorage() async {
    File userImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(firebaseUser.uid + '.jpg');
    final StorageUploadTask uploadTask = firebaseStorageRef.putFile(userImage);
    imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {});
  }

  Future<DocumentSnapshot> _loadUserData() async {
    firebaseUser = await _auth.currentUser();
    user = await Firestore.instance.collection('users').document(firebaseUser.uid).get();
    final ref = FirebaseStorage.instance.ref().child(firebaseUser.uid + '.jpg');
    imageURL = await ref.getDownloadURL();
    return user;
  }

  Query _loadHighscoreUser() {
    return Firestore.instance.collection('users').orderBy('xp', descending: true).limit(10);
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
