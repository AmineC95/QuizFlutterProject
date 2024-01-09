import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../widgets/quiz_question_widget.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Question>> futureQuestions;
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    futureQuestions = fetchQuestions();
  }

  Future<List<Question>> fetchQuestions() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/worldline/learning-kotlin-multiplatform/main/quiz.json'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> questionsJson = data['questions'];
      questions = questionsJson.map((json) => Question.fromJson(json)).toList();
      return questions;
    } else {
      throw Exception(
          'Failed to load questions. Error: ${response.reasonPhrase}');
    }
  }

  void answerQuestion(bool isCorrect) {
    if (isCorrect) {
      score++;
    }

    setState(() {
      currentQuestionIndex++;
    });

    if (currentQuestionIndex >= questions.length) {
      Navigator.pushReplacementNamed(context, '/score', arguments: score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Question>>(
      future: futureQuestions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            var currentQuestion = snapshot.data![currentQuestionIndex];

            return QuizQuestionWidget(
              question: currentQuestion,
              onAnswerSelected: (bool isCorrect) {
                answerQuestion(isCorrect);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
