import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  String _userName = 'User';
  int _steps = 0;
  int _calories = 0;
  int _workouts = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final name = await _storageService.getUserName();
    final steps = await _storageService.getSteps();
    final calories = await _storageService.getCalories();
    final logs = await _storageService.getWorkoutLogs();
    setState(() {
      _userName = name;
      _steps = steps;
      _calories = calories;
      _workouts = logs.length;
      _isLoading = false;
    });
  }

  Future<void> _updateSteps() async {
    final controller = TextEditingController(text: _steps.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text(
          '👟 Update Steps',
          style: TextStyle(color: textColor, fontFamily: fontFamily),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: textColor),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            labelStyle: TextStyle(color: hintColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: hintColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: hintColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              final steps = int.tryParse(controller.text) ?? 0;
              await _storageService.saveSteps(steps);
              await _notificationService.showGoalReminder();
              Navigator.pop(context);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor),
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCalories() async {
    final controller = TextEditingController(text: _calories.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text(
          '🔥 Update Calories',
          style: TextStyle(color: textColor, fontFamily: fontFamily),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: textColor),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Calories Burned',
            labelStyle: TextStyle(color: hintColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: hintColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: hintColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              final calories = int.tryParse(controller.text) ?? 0;
              await _storageService.saveCalories(calories);
              await _notificationService.showWaterReminder();
              Navigator.pop(context);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor),
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $_userName! 👋',
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
                              ),
                            ),
                            const Text(
                              'Let\'s crush your goals today!',
                              style: TextStyle(
                                color: hintColor,
                                fontSize: 14,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        // Profile Avatar
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Today's Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryColor, Color(0xFF9C94FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Summary",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_workouts Workouts Completed',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _summaryItem(
                                  '👟', '$_steps', 'Steps'),
                              _summaryItem(
                                  '🔥', '$_calories', 'Calories'),
                              _summaryItem(
                                  '💪', '$_workouts', 'Workouts'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _actionCard(
                            icon: Icons.directions_walk,
                            title: 'Update Steps',
                            subtitle: '$_steps steps',
                            color: Colors.blue,
                            onTap: _updateSteps,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionCard(
                            icon: Icons.local_fire_department,
                            title: 'Log Calories',
                            subtitle: '$_calories kcal',
                            color: Colors.orange,
                            onTap: _updateCalories,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _actionCard(
                            icon: Icons.notifications,
                            title: 'Workout Reminder',
                            subtitle: 'Tap to remind',
                            color: Colors.purple,
                            onTap: () async {
                              await _notificationService
                                  .showWorkoutReminder();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('💪 Workout reminder sent!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionCard(
                            icon: Icons.water_drop,
                            title: 'Water Reminder',
                            subtitle: 'Stay hydrated',
                            color: Colors.cyan,
                            onTap: () async {
                              await _notificationService
                                  .showWaterReminder();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🥤 Water reminder sent!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Goals Progress
                    const Text(
                      'Daily Goals',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _goalCard(
                      title: 'Steps Goal',
                      current: _steps,
                      goal: 10000,
                      icon: Icons.directions_walk,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _goalCard(
                      title: 'Calories Goal',
                      current: _calories,
                      goal: 500,
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _goalCard(
                      title: 'Workouts Goal',
                      current: _workouts,
                      goal: 3,
                      icon: Icons.fitness_center,
                      color: primaryColor,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _summaryItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: hintColor,
                fontFamily: fontFamily,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalCard({
    required String title,
    required int current,
    required int goal,
    required IconData icon,
    required Color color,
  }) {
    double progress = (current / goal).clamp(0.0, 1.0);
    int percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: textColor,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current / $goal',
                style: const TextStyle(
                  color: hintColor,
                  fontFamily: fontFamily,
                  fontSize: 12,
                ),
              ),
              Text(
                current >= goal ? '✅ Goal Reached!' : '🎯 Keep going!',
                style: TextStyle(
                  color: current >= goal ? Colors.green : hintColor,
                  fontFamily: fontFamily,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}