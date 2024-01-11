import 'answer.dart';
import 'dart:convert';

class Question {
  final int id;
  final String label;
  final int correctAnswerId;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.label,
    required this.correctAnswerId,
    required this.answers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'correct_answer_id': correctAnswerId,
      'answers': json.encode(answers.map((a) => a.toJson()).toList()),
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    List<Answer> answers = (json['answers'] as List)
        .map((answerJson) => Answer.fromJson(answerJson))
        .toList();

    return Question(
      id: json['id'],
      label: json['label'],
      correctAnswerId: json['correct_answer_id'],
      answers: answers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'correct_answer_id': correctAnswerId,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  static Question fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      label: map['label'],
      correctAnswerId: map['correct_answer_id'],
      answers: List<Answer>.from(
          json.decode(map['answers']).map((x) => Answer.fromJson(x))),
    );
  }
}
