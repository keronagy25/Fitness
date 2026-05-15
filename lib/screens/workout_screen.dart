import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/colors.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  late TabController _tabController;
  List<Exercise> _exercises = [];
  List<WorkoutLog> _logs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final exercises = await _apiService.fetchExercises();
      final logs = await _storageService.getWorkoutLogs();
      setState(() {
        _exercises = exercises;
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Exercise> get _filteredExercises {
    if (_searchQuery.isEmpty) return _exercises;
    return _exercises
        .where((e) =>
            e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _logWorkout(Exercise exercise) async {
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                exercise.name,
                style: const TextStyle(
                  color: textColor,
                  fontFamily: fontFamily,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                exercise.category,
                style: const TextStyle(
                  color: primaryColor,
                  fontFamily: fontFamily,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sets Field
            TextField(
              controller: setsController,
              style: const TextStyle(color: textColor),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sets',
                labelStyle: const TextStyle(color: hintColor),
                prefixIcon:
                    const Icon(Icons.repeat, color: primaryColor),
                filled: true,
                fillColor: backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reps Field
            TextField(
              controller: repsController,
              style: const TextStyle(color: textColor),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reps',
                labelStyle: const TextStyle(color: hintColor),
                prefixIcon: const Icon(Icons.numbers,
                    color: primaryColor),
                filled: true,
                fillColor: backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: hintColor),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final log = WorkoutLog(
                exerciseName: exercise.name,
                sets: int.tryParse(setsController.text) ?? 3,
                reps: int.tryParse(repsController.text) ?? 10,
                date: DateTime.now(),
              );
              await _storageService.saveWorkoutLog(log);
              await _notificationService.showWorkoutReminder();
              Navigator.pop(context);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '✅ ${exercise.name} logged successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Log Workout',
              style: TextStyle(
                color: Colors.white,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLog(int index) async {
    final prefs = await _storageService.getWorkoutLogs();
    prefs.removeAt(index);
    // Save updated list
    final storageService = StorageService();
    await storageService.clearWorkoutLogs();
    for (var log in prefs) {
      await storageService.saveWorkoutLog(log);
    }
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Workout log deleted!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return Colors.red;
      case 'back':
        return Colors.blue;
      case 'legs':
        return Colors.green;
      case 'core':
        return Colors.orange;
      case 'cardio':
        return Colors.pink;
      case 'shoulders':
        return Colors.purple;
      case 'arms':
        return Colors.cyan;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: const Text(
          'Workouts 💪',
          style: TextStyle(
            color: textColor,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: hintColor,
          labelStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            Tab(
              icon: const Icon(Icons.fitness_center),
              text: 'Exercises (${_exercises.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'My Logs (${_logs.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Exercises from API
                _buildExercisesTab(),
                // Tab 2: Workout Logs
                _buildLogsTab(),
              ],
            ),
    );
  }

  Widget _buildExercisesTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: textColor),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              hintStyle: const TextStyle(color: hintColor),
              prefixIcon: const Icon(Icons.search, color: hintColor),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: hintColor),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Exercises List
        Expanded(
          child: _filteredExercises.isEmpty
              ? const Center(
                  child: Text(
                    'No exercises found!',
                    style: TextStyle(
                      color: hintColor,
                      fontFamily: fontFamily,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    final categoryColor =
                        _getCategoryColor(exercise.category);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: categoryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(
                            color: textColor,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              exercise.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: hintColor,
                                fontFamily: fontFamily,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                exercise.category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontFamily: fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () => _logWorkout(exercise),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLogsTab() {
    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              color: hintColor,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'No workouts logged yet!',
              style: TextStyle(
                color: textColor,
                fontFamily: fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Go to Exercises tab and log\nyour first workout!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: hintColor,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Log a Workout',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: fontFamily,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[_logs.length - 1 - index]; // Show latest first
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ),
            title: Text(
              log.exerciseName,
              style: const TextStyle(
                color: textColor,
                fontFamily: fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.repeat,
                        color: hintColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${log.sets} Sets × ${log.reps} Reps',
                      style: const TextStyle(
                        color: hintColor,
                        fontFamily: fontFamily,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: hintColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${log.date.day}/${log.date.month}/${log.date.year} '
                      '${log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: hintColor,
                        fontFamily: fontFamily,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red),
              onPressed: () => _deleteLog(
                  _logs.length - 1 - index),
            ),
          ),
        );
      },
    );
  }
}