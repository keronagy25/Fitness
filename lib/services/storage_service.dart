import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkoutLog {
  final String exerciseName;
  final int sets;
  final int reps;
  final DateTime date;

  WorkoutLog({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'exerciseName': exerciseName,
        'sets': sets,
        'reps': reps,
        'date': date.toIso8601String(),
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        exerciseName: json['exerciseName'],
        sets: json['sets'],
        reps: json['reps'],
        date: DateTime.parse(json['date']),
      );
}

class StorageService {
  // Save workout log
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('workout_logs') ?? [];
    logs.add(json.encode(log.toJson()));
    await prefs.setStringList('workout_logs', logs);
  }

  // Get all workout logs
  Future<List<WorkoutLog>> getWorkoutLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('workout_logs') ?? [];
    return logs.map((e) => WorkoutLog.fromJson(json.decode(e))).toList();
  }

  // Save daily steps
  Future<void> saveSteps(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_steps', steps);
  }

  // Get daily steps
  Future<int> getSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_steps') ?? 0;
  }

  // Save calories burned
  Future<void> saveCalories(int calories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calories_burned', calories);
  }

  // Get calories burned
  Future<int> getCalories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('calories_burned') ?? 0;
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workout_logs');
    await prefs.remove('daily_steps');
    await prefs.remove('calories_burned');
  }
  // Save user name
Future<void> saveUserName(String name) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_name', name);
}

// Get user email
Future<String> getUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_email') ?? '';
}

// Save weight
Future<void> saveWeight(String weight) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_weight', weight);
}

// Get weight
Future<String> getWeight() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_weight') ?? '';
}

// Save height
Future<void> saveHeight(String height) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_height', height);
}

// Get height
Future<String> getHeight() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_height') ?? '';
}

  Future<void> clearWorkoutLogs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('workout_logs');
  }

  // Get user name
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'User';
  }
}