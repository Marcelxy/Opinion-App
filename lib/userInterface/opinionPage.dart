import 'package:flutter/material.dart';
import 'package:opinion_app/userInterface/profilPage.dart';
import 'package:opinion_app/userInterface/questionPage.dart';
import 'package:opinion_app/userInterface/myQuestionPage.dart';

class OpinionPage extends StatefulWidget {
  @override
  _OpinionPageState createState() => _OpinionPageState();
}

class _OpinionPageState extends State<OpinionPage> {
  int currentPageNumber = 0;
  final List<Widget> pages = [
    QuestionPage(),
    MyQuestionPage(),
    ProfilPage(),
  ];
  Widget currentPage = QuestionPage();
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: bucket, child: currentPage),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer, color: currentPageNumber == 0 ? Color.fromRGBO(143, 148, 251, 1) : Colors.grey),
            title: Text(
              'Fragen',
              style: TextStyle(color: currentPageNumber == 0 ? Color.fromRGBO(143, 148, 251, 1) : Colors.grey),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, color: currentPageNumber == 1 ? Color.fromRGBO(143, 148, 251, 1) : Colors.grey),
            title: Text(
              'Meine Fragen',
              style: TextStyle(color: currentPageNumber == 1 ? Color.fromRGBO(143, 148, 251, 1) : Colors.grey),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: currentPageNumber == 2 ? Color.fromRGBO(143, 148, 251, 1) : Colors.grey),
            title: Text(
              'Profil',
              style: TextStyle(color: currentPageNumber == 2 ? Color.fromRGBO(143, 148, 251, 1) : Colors.grey),
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
          currentPage = QuestionPage();
          currentPageNumber = 0;
          break;
        case 1:
          currentPage = MyQuestionPage();
          currentPageNumber = 1;
          break;
        case 2:
          currentPage = ProfilPage();
          currentPageNumber = 2;
          break;
      }
    });
  }
}