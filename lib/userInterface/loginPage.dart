import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';
import 'package:opinion_app/userInterface/opinionPage.dart';
import 'package:opinion_app/userInterface/registerPage.dart';
import 'package:opinion_app/userInterface/forgotPasswordPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
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
    _progressDialog.style(message: 'Login...');
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
                            child: Text('Login',
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
                          key: _loginFormKey,
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
                                  onPressed: () => _login(context),
                                  child: Text(
                                    'Login',
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
                      height: 20.0,
                    ),
                    FadeAnimation(
                      1.5,
                      GestureDetector(
                        onTap: () => _toPage(context, ForgotPasswordPage()),
                        child: Text(
                          'Passwort vergessen?',
                          style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                    FadeAnimation(
                      1.5,
                      GestureDetector(
                        onTap: () => _toPage(context, RegisterPage()),
                        child: Text(
                          'Zur Registrierung',
                          style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
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

  String _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Bitte Passwort eingeben.';
    } else {
      return null;
    }
  }

  Future<void> _login(BuildContext context) async {
    bool loginSuccessful = false;
    String errorMessage;
    var internetConnectivity = await (Connectivity().checkConnectivity());
    if (internetConnectivity == ConnectivityResult.mobile || internetConnectivity == ConnectivityResult.wifi) {
      if (_loginFormKey.currentState.validate()) {
        _progressDialog.show();
        try {
          final FirebaseAuth auth = FirebaseAuth.instance;
          await auth.signInWithEmailAndPassword(email: _email.text.toString(), password: _password.text.toString());
          loginSuccessful = true;
        } catch (error) {
          switch (error.code) {
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