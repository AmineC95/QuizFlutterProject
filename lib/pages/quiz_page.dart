// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../widgets/quiz_question_widget.dart';
import '../data/database.dart';

import 'package:http/http.dart' as http;

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Future<List<Question>> futureQuestions = Future.value([]);
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  final DatabaseManager dbManager = DatabaseManager();

  @override
  void initState() {
    super.initState();
    initializeQuestions();
  }

  void initializeQuestions() async {
    var isConnected = await checkInternetConnection();
    print('Internet connected: $isConnected');
    if (isConnected) {
      futureQuestions = fetchQuestionsFromAPI();
    } else {
      // Si pas de connexion, charge depuis la BDD
      futureQuestions = dbManager.fetchQuestionsFromDB();
    }
    setState(() {});
  }

  Future<List<Question>> fetchQuestionsFromAPI() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/worldline/learning-kotlin-multiplatform/main/quiz.json'));

    if (response.statusCode == 200) {
      print('Questions from API: ${response.body}');
      final data = json.decode(response.body);
      final questionsJson = data['questions'] as List;
      List<Question> questions =
          questionsJson.map((json) => Question.fromJson(json)).toList();

      await dbManager.storeQuestionsInDB(questions);
      return questions;
    } else {
      print('Failed to load questions from API');
      throw Exception('Failed to load questions from API');
    }
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  List<Question> getMockQuestions() {
    return [
      Question(
        id: 1,
        label: "Quelle est la capitale de la France ?",
        correctAnswerId: 2,
        answers: [
          Answer(id: 1, label: "Berlin"),
          Answer(id: 2, label: "Paris"),
          Answer(id: 3, label: "Londres"),
          Answer(id: 4, label: "Rome"),
        ],
      ),
      Question(
        id: 2,
        label: "Quelle est la planète la plus proche du soleil ?",
        correctAnswerId: 1,
        answers: [
          Answer(id: 1, label: "Mercure"),
          Answer(id: 2, label: "Vénus"),
          Answer(id: 3, label: "Terre"),
          Answer(id: 4, label: "Mars"),
        ],
      ),
      Question(
        id: 3,
        label: "Combien de continents y a-t-il sur Terre ?",
        correctAnswerId: 4,
        answers: [
          Answer(id: 1, label: "3"),
          Answer(id: 2, label: "5"),
          Answer(id: 3, label: "6"),
          Answer(id: 4, label: "7"),
        ],
      ),
      Question(
        id: 4,
        label: "Quel est le plus grand mammifère terrestre ?",
        correctAnswerId: 3,
        answers: [
          Answer(id: 1, label: "Éléphant"),
          Answer(id: 2, label: "Rhinocéros"),
          Answer(id: 3, label: "Baleine bleue"),
          Answer(id: 4, label: "Gorille"),
        ],
      ),
      Question(
        id: 5,
        label: "Qui a peint la Mona Lisa ?",
        correctAnswerId: 2,
        answers: [
          Answer(id: 1, label: "Pablo Picasso"),
          Answer(id: 2, label: "Leonardo da Vinci"),
          Answer(id: 3, label: "Vincent van Gogh"),
          Answer(id: 4, label: "Michel-Ange"),
        ],
      ),
    ];
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Question $currentQuestionIndex'),
      ),
      body: FutureBuilder<List<Question>>(
        future: futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return FutureBuilder<List<Question>>(
              future: Future.value(getMockQuestions()),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Aucune question disponible'));
                }

                questions = snapshot.data!;
                if (currentQuestionIndex >= questions.length) {
                  return const Center(child: Text('No more questions'));
                }

                var currentQuestion = questions[currentQuestionIndex];

                return QuizQuestionWidget(
                  question: currentQuestion,
                  onAnswerSelected: (bool isCorrect) {
                    answerQuestion(isCorrect);
                  },
                );
              },
            );
          }

          questions = snapshot.data!;
          if (currentQuestionIndex >= questions.length) {
            return const Center(child: Text('No more questions'));
          }

          var currentQuestion = questions[currentQuestionIndex];

          return QuizQuestionWidget(
            question: currentQuestion,
            onAnswerSelected: (bool isCorrect) {
              answerQuestion(isCorrect);
            },
          );
        },
      ),
    );
  }
}
