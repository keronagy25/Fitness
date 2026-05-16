import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutLog {
  final String? id;
  final String exerciseName;
  final int sets;
  final int reps;
  final DateTime date;

  WorkoutLog({
    this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'exerciseName': exerciseName,
        'sets': sets,
        'reps': reps,
        'date': date.toIso8601String(),
      };

  factory WorkoutLog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutLog(
      id: doc.id,
      exerciseName: data['exerciseName'],
      sets: data['sets'],
      reps: data['reps'],
      date: DateTime.parse(data['date']),
    );
  }
}

class StorageService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  CollectionReference get _logsRef =>
      _db.collection('users').doc(_userId).collection('workout_logs');

  DocumentReference get _statsRef =>
      _db.collection('users').doc(_userId).collection('daily_stats').doc(_today);

  DocumentReference get _userRef =>
      _db.collection('users').doc(_userId);

  // ── Workout Logs ──────────────────────────────────────────

  Future<void> saveWorkoutLog(WorkoutLog log) async {
    await _logsRef.add(log.toMap());
  }

  Future<List<WorkoutLog>> getWorkoutLogs() async {
    final snapshot = await _logsRef.orderBy('date').get();
    return snapshot.docs.map(WorkoutLog.fromDoc).toList();
  }

  Future<void> deleteWorkoutLog(String id) async {
    await _logsRef.doc(id).delete();
  }

  Future<void> clearWorkoutLogs() async {
    final snapshot = await _logsRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ── Daily Stats ───────────────────────────────────────────

  Future<void> saveSteps(int steps) async {
    await _statsRef.set({'steps': steps}, SetOptions(merge: true));
  }

  Future<int> getSteps() async {
    final doc = await _statsRef.get();
    if (!doc.exists) return 0;
    return (doc.data() as Map<String, dynamic>)['steps'] ?? 0;
  }

  Future<void> saveCalories(int calories) async {
    await _statsRef.set({'calories': calories}, SetOptions(merge: true));
  }

  Future<int> getCalories() async {
    final doc = await _statsRef.get();
    if (!doc.exists) return 0;
    return (doc.data() as Map<String, dynamic>)['calories'] ?? 0;
  }

  // ── User Profile ──────────────────────────────────────────

  Future<String> getUserName() async {
    final doc = await _userRef.get();
    if (!doc.exists) return 'User';
    return (doc.data() as Map<String, dynamic>)['name'] ?? 'User';
  }

  Future<void> saveUserName(String name) async {
    await _userRef.set({'name': name}, SetOptions(merge: true));
  }

  Future<String> getUserEmail() async {
    final doc = await _userRef.get();
    if (!doc.exists) return '';
    return (doc.data() as Map<String, dynamic>)['email'] ?? '';
  }

  Future<String> getWeight() async {
    final doc = await _userRef.get();
    if (!doc.exists) return '';
    return (doc.data() as Map<String, dynamic>)['weight'] ?? '';
  }

  Future<void> saveWeight(String weight) async {
    await _userRef.set({'weight': weight}, SetOptions(merge: true));
  }

  Future<String> getHeight() async {
    final doc = await _userRef.get();
    if (!doc.exists) return '';
    return (doc.data() as Map<String, dynamic>)['height'] ?? '';
  }

  Future<void> saveHeight(String height) async {
    await _userRef.set({'height': height}, SetOptions(merge: true));
  }

  // ── Clear All ─────────────────────────────────────────────

  Future<void> clearAll() async {
    await clearWorkoutLogs();
    await _statsRef.delete();
  }
}