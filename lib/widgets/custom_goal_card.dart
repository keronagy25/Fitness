import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Custom Goal Card Widget
/// 
/// A reusable widget that displays a goal with progress bar
/// Features:
/// - Customizable title, current value, and goal value
/// - Color-coded progress bar
/// - Percentage display
/// - Goal reached indicator
/// 
/// Created by: [Your Name]
/// GitHub: [Your GitHub Repository URL]
/// Date: [Current Date]
class CustomGoalCard extends StatelessWidget {
  // Required parameters
  final String title;
  final int current;
  final int goal;
  final IconData icon;
  final Color color;
  
  // Optional parameters with defaults
  final bool showPercentage;
  final bool showGoalReachedMessage;
  final double borderRadius;
  final double padding;
  
  const CustomGoalCard({
    Key? key,
    required this.title,
    required this.current,
    required this.goal,
    required this.icon,
    required this.color,
    this.showPercentage = true,
    this.showGoalReachedMessage = true,
    this.borderRadius = 16,
    this.padding = 16,
  }) : super(key: key);

  // Computed properties
  double get _progress => (current / goal).clamp(0.0, 1.0);
  int get _percentage => (_progress * 100).toInt();
  bool get _isGoalReached => current >= goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        // Optional: Add border when goal is reached
        border: _isGoalReached
            ? Border.all(color: Colors.green.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Column(
        children: [
          // Header Row: Title and Percentage
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
              if (showPercentage)
                Text(
                  '$_percentage%',
                  style: TextStyle(
                    color: color,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Footer Row: Current/Goal and Status Message
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
              if (showGoalReachedMessage)
                Text(
                  _isGoalReached ? '✅ Goal Reached!' : '🎯 Keep going!',
                  style: TextStyle(
                    color: _isGoalReached ? Colors.green : hintColor,
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

/// Additional custom widget: CustomSummaryItem
/// Extracted from the _summaryItem method
class CustomSummaryItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  
  const CustomSummaryItem({
    Key? key,
    required this.emoji,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

/// Additional custom widget: CustomActionCard
/// Extracted from the _actionCard method
class CustomActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  
  const CustomActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}