import 'package:flutter/material.dart';
import 'package:opinion_app/util/theme.dart';
import 'package:opinion_app/util/colors.dart';
import 'package:connectivity/connectivity.dart';
import 'package:opinion_app/widgets/clock.dart';
import 'package:opinion_app/widgets/light1.dart';
import 'package:opinion_app/widgets/light2.dart';
import 'package:opinion_app/widgets/heading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:opinion_app/util/systemSettings.dart';
import 'package:opinion_app/userInterface/loginPage.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';
import 'package:opinion_app/userInterface/opinionPage.dart';

void main() => runApp(
      MaterialApp(
        theme: buildOpinionAppTheme(),
        debugShowCheckedModeBanner: false,
        home: RegisterPage(),
      ),
    );

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProgressDialog _progressDialog;
  bool _obscurePassword;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // automatischer Login
    getUser().then((user) {
      if (user != null) {
        _toPage(context, OpinionPage());
      }
    });
    _obscurePassword = false;
    _progressDialog = ProgressDialog(context);
    _progressDialog.style(message: 'Registrierung...');
    SystemSettings.allowOnlyPortraitOrientation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Light1(),
                    Light2(),
                    Clock(),
                    Heading(heading: 'Registrierung'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
                child: Column(
                  children: <Widget>[
                    FadeAnimation(
                      1.8,
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: secondaryBackgroundWhite,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.4),
                              blurRadius: 20.0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _registerFormKey,
                          child: Column(
                            children: <Widget>[
                              _usernameTextFormField(),
                              _emailTextFormField(),
                              _passwordTextFormField(),
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
                          borderRadius: BorderRadius.circular(12.0),
                          gradient: LinearGradient(
                            colors: [
                              primaryBlue,
                              primaryBlue.withOpacity(0.6),
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
                                    style: const TextStyle(
                                        color: textOnSecondaryWhite, fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 21.0,
                    ),
                    FadeAnimation(
                      1.5,
                      GestureDetector(
                        onTap: () => _toPage(context, LoginPage()),
                        child: Text(
                          'Zum Login',
                          style: const TextStyle(color: primaryBlue, fontSize: 16.0),
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

  /// ////////////////////////////////////////
  ///     Benutzername Eingabefeld
  /// ////////////////////////////////////////

  Widget _usernameTextFormField() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        child: TextFormField(
          decoration: InputDecoration(
            icon: Icon(Icons.person, size: IconTheme.of(context).size, color: IconTheme.of(context).color),
            labelText: 'Benutzername...',
            counterText: '',
          ),
          keyboardType: TextInputType.text,
          controller: _username,
          validator: _validateUsername,
          maxLength: 20,
        ),
      );

  String _validateUsername(String username) {
    int minLength = 3;
    if (username.trim().isEmpty) {
      return 'Bitte Benutzername eingeben.';
    } else if (username.length < minLength) {
      return 'Mindestens $minLength Zeichen benötigt.';
    } else {
      return null;
    }
  }

  /// ////////////////////////////////////////
  ///     E-Mail Eingabefeld
  /// ////////////////////////////////////////

  Widget _emailTextFormField() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        child: TextFormField(
          decoration: InputDecoration(
            icon: Icon(Icons.email, size: IconTheme.of(context).size, color: IconTheme.of(context).color),
            labelText: 'E-Mail...',
            counterText: '',
          ),
          keyboardType: TextInputType.emailAddress,
          controller: _email,
          validator: _validateEmail,
          maxLength: 70,
        ),
      );

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

  /// ////////////////////////////////////////
  ///     Passwort Eingabefeld
  /// ////////////////////////////////////////

  Widget _passwordTextFormField() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        child: TextFormField(
          decoration: InputDecoration(
            icon: Icon(Icons.lock, size: IconTheme.of(context).size, color: IconTheme.of(context).color),
            suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,
                    size: IconTheme.of(context).size, color: IconTheme.of(context).color),
                onPressed: () => _showPassword()),
            labelText: 'Passwort...',
            counterText: '',
          ),
          obscureText: _obscurePassword ? false : true,
          controller: _password,
          validator: _validatePassword,
          maxLength: 50,
        ),
      );

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

  void _showPassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  /// ////////////////////////////////////////
  ///           Registrierung
  /// ////////////////////////////////////////

  _register(BuildContext context) async {
    bool registerSuccessful = false;
    String errorMessage;
    var internetConnectivity = await (Connectivity().checkConnectivity());
    if (internetConnectivity == ConnectivityResult.mobile || internetConnectivity == ConnectivityResult.wifi) {
      if (_registerFormKey.currentState.validate()) {
        _progressDialog.show();
        try {
          final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
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

  _createUserInCloudFirestore(FirebaseUser user) async {
    try {
      final userSnapshot = await Firestore.instance.collection('users').document(user.uid).get();
      if (userSnapshot == null || !userSnapshot.exists) {
        Firestore.instance.collection('users').document(user.uid).setData({
          'email': user.email,
          'username': _username.text.toString(),
          'xp': 0,
          'questionRepository': {},
          'releasedQuestions': {},
          'notReleasedQuestions': {},
          'completedQuestions': {}
        });
      }
    } catch (error) {
      print('CREATE USER IN CLOUD FIRESTORE ERROR: ' + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Benutzer Registrierung fehlgeschlagen. Bitte erneut versuchen.'),
      ));
    }
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  void _toPage(BuildContext context, Widget page) {
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    });
  }
}