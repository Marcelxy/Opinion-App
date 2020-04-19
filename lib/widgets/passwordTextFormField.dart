import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ////////////////////////////////////////
///         Passwort Eingabefeld
/// ////////////////////////////////////////

class PasswordTextFormField extends StatefulWidget {
  final void Function(String password) onSaved;

  const PasswordTextFormField({Key key, this.onSaved}) : super(key: key);

  @override
  _PasswordTextFormFieldState createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: TextFormField(
        style: GoogleFonts.cormorantGaramond(
          textStyle: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        onSaved: widget.onSaved,
      ),
    );
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

  void _showPassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
}
