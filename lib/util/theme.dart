import 'package:flutter/material.dart';
import 'package:opinion_app/util/colors.dart';

final ThemeData _opinionAppTheme = buildOpinionAppTheme();

ThemeData buildOpinionAppTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    accentColor: primaryBlueDark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: secondaryBackgroundWhite,
    textTheme: _buildOpinionAppTextTheme(base.textTheme),
    inputDecorationTheme: _buildOpinionAppInputDecorationTheme(base.inputDecorationTheme),
    iconTheme: _buildOpinionAppIconTheme(base.iconTheme),
    floatingActionButtonTheme: _buildOpinionAppFloatingActionButtonTheme(base.floatingActionButtonTheme),
  );
}

_buildOpinionAppTextTheme(TextTheme base) {
  return base.copyWith(
    body1: TextStyle(
      color: textOnPrimaryBlack,
      fontSize: 14.0,
    ),
  );
}

_buildOpinionAppInputDecorationTheme(InputDecorationTheme base) {
  return base.copyWith(
    labelStyle: TextStyle(color: primaryBlue),
    contentPadding: EdgeInsets.only(bottom: 12.0),
  );
}

_buildOpinionAppIconTheme(IconThemeData base) {
  return base.copyWith(
    size: 25.0,
    color: secondaryBlue,
  );
}

_buildOpinionAppFloatingActionButtonTheme(FloatingActionButtonThemeData base) {
  return base.copyWith(
    elevation: 6.0,
    splashColor: primaryBlueDark,
    backgroundColor: primaryBlue,
  );
}
