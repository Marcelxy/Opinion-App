import 'package:flutter/material.dart';
import 'dart:io';
import 'package:opinion_app/util/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opinion_app/util/systemSettings.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:opinion_app/userInterface/loginPage.dart';
import 'package:opinion_app/userInterface/adminConsolePage.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _firebaseUser;
  DocumentSnapshot _user;
  var _imageURL;

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
        title: Text(
          'Profil',
          style: GoogleFonts.cormorantGaramond(
            textStyle: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
            height: (MediaQuery.of(context).size.height / 100) * 33,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, Colors.blue.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100.0),
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
                        if (snapshot.connectionState == ConnectionState.none ||
                            snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.connectionState == ConnectionState.done) {
                          return Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 28.0),
                                child: _imageURL == null ? noUserImage() : displayUserImage(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 28.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        'E-Mail:\n' + _user.data['email'],
                                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        'Benutzername:\n' + _user.data['username'],
                                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      'Erfahrungspunkte:\n' + _user.data['xp'].toString(),
                                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                                    ),
                                  ],
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
            height: (MediaQuery.of(context).size.height / 100) * 45,
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
                    return Container(
                      child: Card(
                        elevation: 4.0,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              document['username'][0],
                              style: GoogleFonts.cormorantGaramond(
                                textStyle: TextStyle(
                                  fontSize: 19.0,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            document['username'],
                            style: GoogleFonts.cormorantGaramond(
                              textStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          trailing: Text(
                            document['xp'].toString(),
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
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
              backgroundImage: NetworkImage(_imageURL),
            ),
          ),
        ],
      ),
    );
  }

  _saveUserImageInCloudStorage() async {
    File userImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(_firebaseUser.uid + '.jpg');
    final StorageUploadTask uploadTask = firebaseStorageRef.putFile(userImage);
    _imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {});
  }

  Future<DocumentSnapshot> _loadUserData() async {
    _firebaseUser = await _auth.currentUser();
    _user = await Firestore.instance.collection('users').document(_firebaseUser.uid).get();
    final ref = FirebaseStorage.instance.ref().child(_firebaseUser.uid + '.jpg');
    _imageURL = await ref.getDownloadURL();
    return _user;
  }

  Query _loadHighscoreUser() {
    return Firestore.instance.collection('users').orderBy('xp', descending: true).limit(10);
  }

  bool _isAdmin() {
    if (_firebaseUser.email == "marcel.geirhos@gmail.com") {
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
