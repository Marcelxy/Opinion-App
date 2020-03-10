import 'package:flutter/material.dart';
import 'package:opinion_app/models/user.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:opinion_app/userInterface/loginPage.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';
import 'package:opinion_app/userInterface/opinionPage.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: RegisterPage()));

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  ProgressDialog _progressDialog;
  bool _obscurePassword;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _obscurePassword = false;
    _progressDialog = new ProgressDialog(context);
    _progressDialog.style(message: 'Registrierung...');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/loginBackground.png'), fit: BoxFit.fill),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: FadeAnimation(
                        1,
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/light1.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeAnimation(
                        1,
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/light2.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: FadeAnimation(
                        1.3,
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/clock.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      child: FadeAnimation(
                        1.6,
                        Container(
                          margin: EdgeInsets.only(top: 70),
                          child: Center(
                            child: Text('Registrierung',
                                style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
                child: Column(
                  children: <Widget>[
                    FadeAnimation(
                      1.8,
                      Container(
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, 0.4),
                              blurRadius: 20.0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _registerFormKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.email, size: 25.0, color: Color.fromRGBO(143, 148, 251, 0.95)),
                                    labelText: 'E-Mail...',
                                    labelStyle: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                                    contentPadding: EdgeInsets.only(bottom: 12.0),
                                    isDense: true,
                                    counterText: '',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _email,
                                  validator: _validateEmail,
                                  maxLength: 70,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.lock, size: 25.0, color: Color.fromRGBO(143, 148, 251, 0.95)),
                                    suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,
                                            size: 25.0, color: Color.fromRGBO(143, 148, 251, 0.95)),
                                        onPressed: () => _showPassword()),
                                    labelText: 'Passwort...',
                                    labelStyle: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                                    contentPadding: EdgeInsets.only(bottom: 0),
                                    isDense: true,
                                    counterText: '',
                                  ),
                                  obscureText: _obscurePassword ? false : true,
                                  controller: _password,
                                  validator: _validatePassword,
                                  maxLength: 50,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    FadeAnimation(
                      2,
                      Container(
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
                        child: Center(
                          child: ButtonTheme(
                            height: 50,
                            minWidth: 300,
                            child: Builder(
                              builder: (BuildContext context) {
                                return FlatButton(
                                  onPressed: () => _register(context),
                                  child: Text(
                                    'Registrieren',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 42.0,
                    ),
                    FadeAnimation(
                      1.5,
                      GestureDetector(
                        onTap: () => _toPage(context, LoginPage()),
                        child: Text(
                          'Zum Login',
                          style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1), fontSize: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// E-Mail Validierung siehe: https://pub.dev/packages/email_validator
  String _validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Bitte E-Mail eingeben.';
    } else if (EmailValidator.validate(email.trim()) == false) {
      return 'E-Mail Format ist nicht korrekt.';
    } else {
      return null;
    }
  }

  String _validatePassword(String password) {
    int minLength = 6;
    if (password.isEmpty) {
      return 'Bitte Passwort eingeben.';
    } else if (password.length < minLength) {
      return 'Mindestens $minLength Zeichen benötigt.';
    } else {
      return null;
    }
  }

  Future<void> _register(BuildContext context) async {
    bool registerSuccessful = false;
    String errorMessage;
    var internetConnectivity = await (Connectivity().checkConnectivity());
    if (internetConnectivity == ConnectivityResult.mobile || internetConnectivity == ConnectivityResult.wifi) {
      if (_registerFormKey.currentState.validate()) {
        _progressDialog.show();
        try {
          final FirebaseAuth auth = FirebaseAuth.instance;
          final FirebaseUser user = (await auth.createUserWithEmailAndPassword(
                  email: _email.text.toString(), password: _password.text.toString()))
              .user;
          _createUserInCloudFirestore(user);
          registerSuccessful = true;
        } catch (error) {
          switch (error.code) {
            case "ERROR_EMAIL_ALREADY_IN_USE":
              errorMessage = 'E-Mail ist bereits registriert.';
              break;
            default:
              errorMessage = 'Unbekannter Fehler ist aufgetreten. Bitte erneut versuchen.';
          }
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        _progressDialog.hide();
        if (registerSuccessful) {
          _toPage(context, OpinionPage());
        }
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Verbindung konnte nicht hergestellt werden. Bitte überprüfe deine Internetverbindung.')));
    }
  }

  Future<void> _createUserInCloudFirestore(FirebaseUser user) async {
    try {
      final userSnapshot = await Firestore.instance.collection('users').document(user.uid).get();
      if (userSnapshot == null || !userSnapshot.exists) {
        int level = 1;
        int xp = 0;
        Firestore.instance
            .collection('users')
            .document(user.uid)
            .setData({'email': user.email, 'level': level, 'xp': xp});
        User(user.email, level, xp);
      }
    } catch (error) {
      print('CREATE USER ERROR: ' + error);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Registrierung fehlgeschlagen. Bitte erneut versuchen.'),
      ));
    }
  }

  void _showPassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toPage(BuildContext context, Widget page) {
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    });
  }
}