// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/answer.dart';
import '../models/question.dart';
import '../widgets/quiz_question_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
  Database? database;

  @override
  void initState() {
    super.initState();
    initializeDatabase().then((_) {
      initializeQuestions();
    });
  }

  Future<void> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'quiz_database.db');

    database = await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE questions(id INTEGER PRIMARY KEY, label TEXT, correct_answer_id INTEGER, answers TEXT)',
      );
    });
  }

  void initializeQuestions() async {
    if (database == null) return; // Check if database is initialized

    var isConnected = await checkInternetConnection();
    if (isConnected) {
      var lastUpdate = await getLastUpdateTime();
      if (DateTime.now().difference(lastUpdate).inMinutes > 5) {
        futureQuestions = fetchQuestionsFromAPI();
      } else {
        futureQuestions = fetchQuestionsFromDB();
      }
    } else {
      futureQuestions = fetchQuestionsFromDB();
    }
    setState(() {});
  }

  Future<List<Question>> fetchQuestionsFromAPI() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/worldline/learning-kotlin-multiplatform/main/quiz.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final questionsJson = data['questions'] as List;
      questions = questionsJson.map((json) => Question.fromJson(json)).toList();
      storeQuestionsInDB(questions);
      updateLastUpdateTime();
      return questions;
    } else {
      throw Exception(
          'Failed to load questions. Error: ${response.reasonPhrase}');
    }
  }

  Future<List<Question>> fetchQuestionsFromDB() async {
    final List<Map<String, dynamic>> maps = await database!.query('questions');

    if (maps.isEmpty) {
      return getMockQuestions();
    }

    return maps.map((map) {
      final questionData = json.decode(map['answers']) as List;
      final answers =
          questionData.map((data) => Answer.fromJson(data)).toList();
      return Question(
        id: map['id'],
        label: map['label'],
        correctAnswerId: map['correct_answer_id'],
        answers: answers,
      );
    }).toList();
  }

  Future<void> storeQuestionsInDB(List<Question> questions) async {
    for (var question in questions) {
      await database!.insert(
        'questions',
        {
          'id': question.id,
          'label': question.label,
          'correct_answer_id': question.correctAnswerId,
          'answers':
              json.encode(question.answers.map((a) => a.toJson()).toList())
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<DateTime> getLastUpdateTime() async {
    final List<Map<String, dynamic>> maps = await database!.query('meta');
    if (maps.isNotEmpty && maps[0].containsKey('last_update')) {
      return DateTime.parse(maps[0]['last_update']);
    }
    return DateTime.now().subtract(const Duration(days: 1));
  }

  Future<void> updateLastUpdateTime() async {
    await database!.update(
      'meta',
      {'last_update': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  List<Question> getMockQuestions() {
    return [
      Question(
        id: 1,
        label: "Question mock 1",
        correctAnswerId: 1,
        answers: [
          Answer(id: 1, label: "Réponse A"),
          Answer(id: 2, label: "Réponse B")
        ],
      ),
      Question(
        id: 1,
        label: "Question mock 2",
        correctAnswerId: 1,
        answers: [
          Answer(id: 1, label: "Réponse A"),
          Answer(id: 2, label: "Réponse B")
        ],
      ),
      Question(
        id: 1,
        label: "Question mock 3",
        correctAnswerId: 1,
        answers: [
          Answer(id: 1, label: "Réponse A"),
          Answer(id: 2, label: "Réponse B")
        ],
      ),
      Question(
        id: 1,
        label: "Question mock 4",
        correctAnswerId: 1,
        answers: [
          Answer(id: 1, label: "Réponse A"),
          Answer(id: 2, label: "Réponse B")
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
      Navigator.pushReplacementNamed(context as BuildContext, '/score',
          arguments: score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Question>>(
      future: futureQuestions,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // return const Center(child: Text('No questions available'));
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
                return const Center(child: Text('Aucune question disponible'));
              }

              var currentQuestion = snapshot.data![currentQuestionIndex];

              return QuizQuestionWidget(
                question: currentQuestion,
                onAnswerSelected: (bool isCorrect) {
                  answerQuestion(isCorrect);
                },
              );
            },
          );
        }

        if (currentQuestionIndex >= snapshot.data!.length) {
          return const Center(child: Text('No more questions'));
        }

        var currentQuestion = snapshot.data![currentQuestionIndex];

        return QuizQuestionWidget(
          question: currentQuestion,
          onAnswerSelected: (bool isCorrect) {
            answerQuestion(isCorrect);
          },
        );
      },
    );
  }
}
