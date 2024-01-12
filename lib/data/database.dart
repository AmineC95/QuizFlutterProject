import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/question.dart';

class DatabaseManager {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // Initialiser la base de données
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'quiz_database.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Table des questions
        await db.execute(
          'CREATE TABLE questions(id INTEGER PRIMARY KEY, label TEXT, correct_answer_id INTEGER, answers TEXT)',
        );
        // Table pour stocker le dernier temps de mise à jour
        await db.execute(
          'CREATE TABLE meta(id INTEGER PRIMARY KEY, last_update TEXT)',
        );
        // Insérer une valeur initiale pour la métadonnée
        await db.insert(
            'meta', {'id': 1, 'last_update': DateTime.now().toIso8601String()});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Créer la table meta si elle n'existait pas dans les versions précédentes
          await db.execute(
            'CREATE TABLE meta(id INTEGER PRIMARY KEY, last_update TEXT)',
          );
        }
      },
    );
  }

  // Stocker les questions dans la base de données
  Future<void> storeQuestionsInDB(List<Question> questions) async {
    final db = await database;
    for (var question in questions) {
      await db.insert(
        'questions',
        question.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await updateLastUpdateTime();
  }

// Récupérer les questions de la base de données
  Future<List<Question>> fetchQuestionsFromDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('questions');

    return List<Question>.from(maps.map((map) => Question.fromMap(map)));
  }

  // Mettre à jour le dernier temps de mise à jour
  Future<void> updateLastUpdateTime() async {
    final db = await database;
    await db.update(
      'meta',
      {'last_update': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // Obtenir le dernier temps de mise à jour
  Future<DateTime> getLastUpdateTime() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('meta');
    if (maps.isNotEmpty && maps[0].containsKey('last_update')) {
      return DateTime.parse(maps[0]['last_update']);
    }
    return DateTime.now().subtract(const Duration(days: 1));
  }
}
