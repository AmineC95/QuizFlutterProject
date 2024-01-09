import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/quiz_page.dart';
import '../pages/score_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

//tests
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/quiz': (context) => const QuizPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/score') {
          final score = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ScorePage(score: score),
          );
        }
        return null;
      },
    );
  }
}
