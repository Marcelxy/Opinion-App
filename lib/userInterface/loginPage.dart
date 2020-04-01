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
import 'package:opinion_app/animations/fadeAnimation.dart';
import 'package:opinion_app/userInterface/opinionPage.dart';
import 'package:opinion_app/userInterface/registerPage.dart';
import 'package:opinion_app/widgets/emailTextFormField.dart';
import 'package:opinion_app/widgets/passwordTextFormField.dart';
import 'package:opinion_app/userInterface/forgotPasswordPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  ProgressDialog _progressDialog;
  String _email;
  String _password;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _progressDialog = new ProgressDialog(context);
    _progressDialog.style(message: 'Login...');
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
                    Heading(heading: 'Login'),
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
                          key: _loginFormKey,
                          child: Column(
                            children: <Widget>[
                              EMailTextFormField(
                                onSaved: (String email) => _email = email,
                              ),
                              PasswordTextFormField(
                                onSaved: (String password) => _password = password,
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
                                  onPressed: () => _login(context),
                                  child: Text(
                                    'Login',
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
                      height: 23.0,
                    ),
                    FadeAnimation(
                      1.5,
                      GestureDetector(
                        onTap: () => _toPage(context, ForgotPasswordPage()),
                        child: Text(
                          'Passwort vergessen?',
                          style: const TextStyle(color: primaryBlue, fontSize: 16.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 23.0,
                    ),
                    FadeAnimation(
                      1.5,
                      GestureDetector(
                        onTap: () => _toPage(context, RegisterPage()),
                        child: Text(
                          'Zur Registrierung',
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
  ///           Login
  /// ////////////////////////////////////////

  _login(BuildContext context) async {
    bool loginSuccessful = false;
    String errorMessage;
    var internetConnectivity = await (Connectivity().checkConnectivity());
    if (internetConnectivity == ConnectivityResult.mobile || internetConnectivity == ConnectivityResult.wifi) {
      if (_loginFormKey.currentState.validate()) {
        _loginFormKey.currentState.save();
        _progressDialog.show();
        try {
          final FirebaseAuth auth = FirebaseAuth.instance;
          print(_email);
          await auth.signInWithEmailAndPassword(email: _email, password: _password);
          loginSuccessful = true;
        } catch (error) {
          switch (error.code.toString()) {
            case "ERROR_INVALID_EMAIL":
              errorMessage = 'E-Mail Format ist nicht korrekt.';
              break;
            case "ERROR_WRONG_PASSWORD":
              errorMessage = 'Falsches Passwort.';
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
              errorMessage = 'Unbekannter Fehler ist aufgetreten. Versuchen sie es erneut.';
          }
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        _progressDialog.hide();
        if (loginSuccessful) {
          _toPage(context, OpinionPage());
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