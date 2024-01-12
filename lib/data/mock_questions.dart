import '../models/answer.dart';
import '../models/question.dart';

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
