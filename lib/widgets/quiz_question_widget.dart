import 'package:flutter/material.dart';
import '../models/question.dart';

class QuizQuestionWidget extends StatelessWidget {
  final Question question;
  final Function(bool) onAnswerSelected;

  const QuizQuestionWidget({
    Key? key,
    required this.question,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question.label, style: const TextStyle(fontSize: 20)),
        ...question.answers.map((answer) => ElevatedButton(
              onPressed: () =>
                  onAnswerSelected(answer.id == question.correctAnswerId),
              child: Text(answer.label),
            )),
      ],
    );
  }
}
