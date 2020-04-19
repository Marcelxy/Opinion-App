import 'package:flutter/material.dart';
import 'package:opinion_app/util/colors.dart';
import 'package:opinion_app/util/systemSettings.dart';
import 'package:opinion_app/userInterface/profilPage.dart';
import 'package:opinion_app/userInterface/questionPage.dart';
import 'package:opinion_app/userInterface/ownQuestionPage.dart';

class OpinionPage extends StatefulWidget {
  @override
  _OpinionPageState createState() => _OpinionPageState();
}

class _OpinionPageState extends State<OpinionPage> {
  int _currentPageNumber;
  final List<Widget> pages = [
    QuestionPage(),
    OwnQuestionPage(),
    ProfilPage(),
  ];
  Widget _currentPage = QuestionPage();
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    _currentPageNumber = 0;
    SystemSettings.allowOnlyPortraitOrientation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _currentPage),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer, color: _currentPageNumber == 0 ? primaryBlue : Colors.grey),
            title: Text(
              'Fragen',
              style: TextStyle(color: _currentPageNumber == 0 ? primaryBlue : Colors.grey, fontSize: 17.5),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, color: _currentPageNumber == 1 ? primaryBlue : Colors.grey),
            title: Text(
              'Meine Fragen',
              style: TextStyle(color: _currentPageNumber == 1 ? primaryBlue : Colors.grey, fontSize: 17.5),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _currentPageNumber == 2 ? primaryBlue : Colors.grey),
            title: Text(
              'Profil',
              style: TextStyle(color: _currentPageNumber == 2 ? primaryBlue : Colors.grey, fontSize: 17.5),
            ),
          ),
        ],
        onTap: (int index) => _showPage(index),
      ),
    );
  }

  void _showPage(int index) {
    setState(() {
      switch (index) {
        case 0:
          _currentPage = QuestionPage();
          _currentPageNumber = 0;
          break;
        case 1:
          _currentPage = OwnQuestionPage();
          _currentPageNumber = 1;
          break;
        case 2:
          _currentPage = ProfilPage();
          _currentPageNumber = 2;
          break;
      }
    });
  }
}