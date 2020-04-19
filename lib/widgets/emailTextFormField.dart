import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';

/// ////////////////////////////////////////
///         E-Mail Eingabefeld
/// ////////////////////////////////////////

class EMailTextFormField extends StatefulWidget {
  final void Function(String email) onSaved;

  const EMailTextFormField({Key key, this.onSaved}) : super(key: key);

  @override
  _EMailTextFormFieldState createState() => _EMailTextFormFieldState();
}

class _EMailTextFormFieldState extends State<EMailTextFormField> {
  final TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
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
          icon: Icon(Icons.email, size: IconTheme.of(context).size, color: IconTheme.of(context).color),
          labelText: 'E-Mail...',
          counterText: '',
        ),
        keyboardType: TextInputType.emailAddress,
        controller: _email,
        validator: _validateEmail,
        maxLength: 70,
        onSaved: widget.onSaved,
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
}
