import 'package:flutter/material.dart';
import 'package:opinion_app/util/colors.dart';
import 'package:connectivity/connectivity.dart';
import 'package:opinion_app/widgets/clock.dart';
import 'package:opinion_app/widgets/light1.dart';
import 'package:opinion_app/widgets/light2.dart';
import 'package:opinion_app/widgets/heading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:opinion_app/util/systemSettings.dart';
import 'package:opinion_app/userInterface/loginPage.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';
import 'package:opinion_app/widgets/emailTextFormField.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _forgotPasswordKey = GlobalKey<FormState>();
  ProgressDialog _progressDialog;
  String _email;

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
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: (MediaQuery.of(context).size.height / 100) * 53,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/loginBackground.png'), fit: BoxFit.fill),
                ),
                child: Stack(
                  children: <Widget>[
                    Light1(),
                    Light2(),
                    Clock(),
                    Heading(heading: 'Zurücksetzen'),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
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
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _forgotPasswordKey,
                          child: Column(
                            children: <Widget>[
                              EMailTextFormField(
                                onSaved: (String email) => _email = email,
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
                            minWidth: (MediaQuery.of(context).size.width / 100) * 80,
                            child: Builder(
                              builder: (BuildContext context) {
                                return FlatButton(
                                  onPressed: () => _resetPassword(context),
                                  child: Text(
                                    'Passwort zurücksetzen',
                                    style: TextStyle(
                                        color: textOnSecondaryWhite, fontSize: 20.0, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    FadeAnimation(
                      1.5,
                      GestureDetector(
                        onTap: () => _toPage(context, LoginPage()),
                        child: Text(
                          'Zum Login',
                          style: TextStyle(color: primaryBlue, fontSize: 18.0, fontWeight: FontWeight.w500),
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
  ///       Passwort zurücksetzen
  /// ////////////////////////////////////////

  _resetPassword(BuildContext context) async {
    bool resetPasswordSuccessful = false;
    String errorMessage;
    var internetConnectivity = await (Connectivity().checkConnectivity());
    if (internetConnectivity == ConnectivityResult.mobile || internetConnectivity == ConnectivityResult.wifi) {
      if (_forgotPasswordKey.currentState.validate()) {
        _forgotPasswordKey.currentState.save();
        _progressDialog.show();
        try {
          final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
          await _firebaseAuth.sendPasswordResetEmail(email: _email);
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
              errorMessage = 'Zu viele ungültige Versuche. Versuchen sie es bitte später erneut.';
              break;
            default:
              errorMessage = 'Unbekannter Fehler ist aufgetreten. Bitte versuche es erneut.';
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
