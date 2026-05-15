import 'dart:convert';
import 'package:http/http.dart' as http;

class Exercise {
  final int id;
  final String name;
  final String description;
  final String category;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });
}

class ApiService {
  // Using a reliable public API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Exercise>> fetchExercises() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts?_limit=20'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        // Map posts to exercises
        List<Exercise> exercises = data.map((item) {
          return Exercise(
            id: item['id'],
            name: _exerciseNames[item['id'] % _exerciseNames.length],
            description: _exerciseDescriptions[item['id'] % _exerciseDescriptions.length],
            category: _categories[item['id'] % _categories.length],
          );
        }).toList();

        return exercises;
      } else {
        return _defaultExercises();
      }
    } catch (e) {
      return _defaultExercises();
    }
  }

  // Exercise names list
  final List<String> _exerciseNames = [
    'Push Ups',
    'Pull Ups',
    'Squats',
    'Lunges',
    'Plank',
    'Burpees',
    'Jumping Jacks',
    'Mountain Climbers',
    'Deadlift',
    'Bench Press',
    'Bicep Curls',
    'Tricep Dips',
    'Shoulder Press',
    'Leg Press',
    'Calf Raises',
    'Russian Twists',
    'Sit Ups',
    'Box Jumps',
    'Kettlebell Swings',
    'Battle Ropes',
  ];

  // Exercise descriptions
  final List<String> _exerciseDescriptions = [
    'Upper body strength exercise targeting chest and triceps',
    'Back and bicep strengthening exercise',
    'Lower body exercise targeting quads and glutes',
    'Single leg exercise for balance and strength',
    'Core strengthening isometric exercise',
    'Full body cardio and strength exercise',
    'Cardio exercise for warm up and conditioning',
    'Core and cardio combination exercise',
    'Full body compound strength exercise',
    'Chest and tricep strength exercise',
  ];

  // Categories
  final List<String> _categories = [
    'Chest',
    'Back',
    'Legs',
    'Core',
    'Cardio',
    'Shoulders',
    'Arms',
    'Full Body',
  ];

  // Default exercises if API fails
  List<Exercise> _defaultExercises() {
    return [
      Exercise(
        id: 1,
        name: 'Push Ups',
        description: 'Upper body strength exercise',
        category: 'Chest',
      ),
      Exercise(
        id: 2,
        name: 'Squats',
        description: 'Lower body strength exercise',
        category: 'Legs',
      ),
      Exercise(
        id: 3,
        name: 'Plank',
        description: 'Core strengthening exercise',
        category: 'Core',
      ),
      Exercise(
        id: 4,
        name: 'Burpees',
        description: 'Full body cardio exercise',
        category: 'Cardio',
      ),
      Exercise(
        id: 5,
        name: 'Pull Ups',
        description: 'Back and bicep exercise',
        category: 'Back',
      ),
    ];
  }
}