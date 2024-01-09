import 'answer.dart';

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
}
