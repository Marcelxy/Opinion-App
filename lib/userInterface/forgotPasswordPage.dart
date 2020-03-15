import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:opinion_app/helper/systemSettings.dart';
import 'package:opinion_app/userInterface/loginPage.dart';

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
      body: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          elevation: 8.0,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _forgotPasswordKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Passwort vergessen',
                    style: TextStyle(fontSize: 22.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email, size: 25.0),
                        labelText: 'E-Mail...',
                        contentPadding: EdgeInsets.only(bottom: 4.0),
                        isDense: true,
                        counterText: '',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                      validator: validateEmail,
                      maxLength: 70,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                    child: Builder(
                      builder: (BuildContext context) {
                        return FlatButton.icon(
                          label: Text('Passwort zurücksetzen'),
                          icon: Icon(Icons.play_arrow),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => _resetPassword(context),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () => _toPage(context, LoginPage()),
                          child: Text('Zurück zum Login'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String validateEmail(String email) {
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