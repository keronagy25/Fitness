import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/storage_service.dart';
import '../utils/colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final StorageService _storageService = StorageService();
  List<WorkoutLog> _logs = [];
  int _steps = 0;
  int _calories = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final logs = await _storageService.getWorkoutLogs();
    final steps = await _storageService.getSteps();
    final calories = await _storageService.getCalories();
    setState(() {
      _logs = logs;
      _steps = steps;
      _calories = calories;
      _isLoading = false;
    });
  }

  // Get workout counts per exercise
  Map<String, int> get _workoutCounts {
    Map<String, int> counts = {};
    for (var log in _logs) {
      counts[log.exerciseName] = (counts[log.exerciseName] ?? 0) + 1;
    }
    return counts;
  }

  // Get weekly workout data (last 7 days)
  List<double> get _weeklyData {
    List<double> data = List.filled(7, 0);
    final now = DateTime.now();
    for (var log in _logs) {
      final diff = now.difference(log.date).inDays;
      if (diff < 7) {
        data[6 - diff] += 1;
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: const Text(
          'Progress 📊',
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Overview
                    _buildStatsOverview(),
                    const SizedBox(height: 24),

                    // Weekly Bar Chart
                    const Text(
                      '📅 Weekly Activity',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBarChart(),
                    const SizedBox(height: 24),

                    // Calories & Steps Line Chart
                    const Text(
                      '📈 Stats Overview',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsCards(),
                    const SizedBox(height: 24),

                    // Pie Chart
                    if (_workoutCounts.isNotEmpty) ...[
                      const Text(
                        '🥧 Workout Distribution',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPieChart(),
                      const SizedBox(height: 24),
                    ],

                    // Recent Activity
                    const Text(
                      '🕐 Recent Activity',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Total\nWorkouts',
            value: '${_logs.length}',
            icon: Icons.fitness_center,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            title: 'Total\nSteps',
            value: '$_steps',
            icon: Icons.directions_walk,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            title: 'Calories\nBurned',
            value: '$_calories',
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: hintColor,
              fontSize: 11,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final weeklyData = _weeklyData;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: weeklyData.reduce((a, b) => a > b ? a : b) + 2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => cardColor,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} workouts',
                  const TextStyle(
                    color: primaryColor,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    days[value.toInt() % 7],
                    style: const TextStyle(
                      color: hintColor,
                      fontFamily: fontFamily,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: hintColor,
                      fontFamily: fontFamily,
                      fontSize: 11,
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: hintColor.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            7,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: weeklyData[index],
                  color: primaryColor,
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: weeklyData.reduce((a, b) => a > b ? a : b) + 2,
                    color: primaryColor.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        // Steps Progress
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Steps',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$_steps',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                const Text(
                  'Goal: 10,000',
                  style: TextStyle(
                    color: hintColor,
                    fontFamily: fontFamily,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_steps / 10000).clamp(0.0, 1.0),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Calories Progress
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Calories',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$_calories',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                const Text(
                  'Goal: 500 kcal',
                  style: TextStyle(
                    color: hintColor,
                    fontFamily: fontFamily,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_calories / 500).clamp(0.0, 1.0),
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.orange),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final counts = _workoutCounts;
    final colors = [
      primaryColor,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.cyan,
      Colors.purple,
    ];

    final entries = counts.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: List.generate(
                  entries.length,
                  (index) {
                    final color = colors[index % colors.length];
                    final value = entries[index].value.toDouble();
                    return PieChartSectionData(
                      color: color,
                      value: value,
                      title: '${value.toInt()}',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(
              entries.length,
              (index) {
                final color = colors[index % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entries[index].key,
                      style: const TextStyle(
                        color: hintColor,
                        fontFamily: fontFamily,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (_logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No activity yet!\nStart logging your workouts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: hintColor,
              fontFamily: fontFamily,
            ),
          ),
        ),
      );
    }

    final recentLogs = _logs.reversed.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentLogs.length,
        separatorBuilder: (context, index) => Divider(
          color: hintColor.withOpacity(0.1),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final log = recentLogs[index];
          return ListTile(
            leading: Container(
              height: 40,
              width: 40,
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
            title: Text(
              log.exerciseName,
              style: const TextStyle(
                color: textColor,
                fontFamily: fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${log.sets} Sets × ${log.reps} Reps',
              style: const TextStyle(
                color: hintColor,
                fontFamily: fontFamily,
                fontSize: 12,
              ),
            ),
            trailing: Text(
              '${log.date.day}/${log.date.month}',
              style: const TextStyle(
                color: primaryColor,
                fontFamily: fontFamily,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}