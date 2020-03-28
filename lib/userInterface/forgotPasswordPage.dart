import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:opinion_app/util/systemSettings.dart';
import 'package:opinion_app/userInterface/loginPage.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _forgotPasswordKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  ProgressDialog _progressDialog;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _progressDialog = new ProgressDialog(context);
    _progressDialog.style(message: 'E-Mail senden...');
    SystemSettings.allowOnlyPortraitOrientation();
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
                            child: Text('Zurücksetzen',
                                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
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
                          key: _forgotPasswordKey,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
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
                                  onPressed: () => _resetPassword(context),
                                  child: Text(
                                    'Passwort zurücksetzen',
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
                      height: 45.0,
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

  String _validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Bitte E-Mail eingeben.';
    } else {
      return null;
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    bool resetPasswordSuccessful = false;
    String errorMessage;
    var internetConnectivity = await (Connectivity().checkConnectivity());
    if (internetConnectivity == ConnectivityResult.mobile || internetConnectivity == ConnectivityResult.wifi) {
      if (_forgotPasswordKey.currentState.validate()) {
        _progressDialog.show();
        try {
          final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
          await _firebaseAuth.sendPasswordResetEmail(email: _email.text.toString());
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('E-Mail zum zurücksetzen des Passworts wurde erfolgreich gesendet.')));
          resetPasswordSuccessful = true;
        } catch (error) {
          switch (error.code) {
            case "ERROR_INVALID_EMAIL":
              errorMessage = 'E-Mail Format ist nicht korrekt.';
              break;
            case "ERROR_USER_NOT_FOUND":
              errorMessage = 'E-Mail ist nicht registriert.';
              break;
            case "ERROR_USER_DISABLED":
              errorMessage = 'Ihr Konto wurde gesperrt. Bitte melden sie sich beim Support.';
              break;
            case "ERROR_TOO_MANY_REQUESTS":
              errorMessage = 'Zu viele Anfragen. Versuchen sie es bitte später erneut.';
              break;
            default:
              errorMessage = 'Unbekannter Fehler ist aufgetreten. Versuchen sie es erneut.';
          }
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        _progressDialog.hide();
        if (resetPasswordSuccessful) {
          _toPage(context, LoginPage());
        }
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Verbindung konnte nicht hergestellt werden. Bitte überprüfe deine Internetverbindung.')));
    }
  }

  void _toPage(BuildContext context, Widget page) {
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    });
  }
}