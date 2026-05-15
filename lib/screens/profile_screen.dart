import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  String _userName = '';
  String _userEmail = '';
  int _totalWorkouts = 0;
  int _totalSteps = 0;
  int _totalCalories = 0;
  bool _isLoading = true;

  // Edit controllers
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _weight = '';
  String _height = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final name = await _storageService.getUserName();
    final email = await _storageService.getUserEmail();
    final logs = await _storageService.getWorkoutLogs();
    final steps = await _storageService.getSteps();
    final calories = await _storageService.getCalories();
    final weight = await _storageService.getWeight();
    final height = await _storageService.getHeight();

    setState(() {
      _userName = name;
      _userEmail = email;
      _totalWorkouts = logs.length;
      _totalSteps = steps;
      _totalCalories = calories;
      _weight = weight;
      _height = height;
      _isLoading = false;
    });
  }

  Future<void> _editProfile() async {
    _nameController.text = _userName;
    _weightController.text = _weight;
    _heightController.text = _height;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '✏️ Edit Profile',
          style: TextStyle(
            color: textColor,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name Field
              TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: textColor,
                  fontFamily: fontFamily,
                ),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(color: hintColor),
                  prefixIcon:
                      const Icon(Icons.person, color: primaryColor),
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Weight Field
              TextField(
                controller: _weightController,
                style: const TextStyle(
                  color: textColor,
                  fontFamily: fontFamily,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: const TextStyle(color: hintColor),
                  prefixIcon: const Icon(Icons.monitor_weight,
                      color: primaryColor),
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Height Field
              TextField(
                controller: _heightController,
                style: const TextStyle(
                  color: textColor,
                  fontFamily: fontFamily,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  labelStyle: const TextStyle(color: hintColor),
                  prefixIcon: const Icon(Icons.height,
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
              await _storageService.saveUserName(
                  _nameController.text.trim());
              await _storageService.saveWeight(
                  _weightController.text.trim());
              await _storageService.saveHeight(
                  _heightController.text.trim());
              Navigator.pop(context);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Profile updated!'),
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
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Save',
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

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🚪 Logout',
          style: TextStyle(
            color: textColor,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: hintColor,
            fontFamily: fontFamily,
          ),
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
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
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

  Future<void> _clearData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🗑️ Clear Data',
          style: TextStyle(
            color: textColor,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will delete all your workout logs, steps and calories. Are you sure?',
          style: TextStyle(
            color: hintColor,
            fontFamily: fontFamily,
          ),
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
              await _storageService.clearAll();
              Navigator.pop(context);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ All data cleared!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text(
              'Clear',
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

  // Calculate BMI
  String get _bmi {
    if (_weight.isEmpty || _height.isEmpty) return 'N/A';
    try {
      double weight = double.parse(_weight);
      double height = double.parse(_height) / 100;
      double bmi = weight / (height * height);
      return bmi.toStringAsFixed(1);
    } catch (e) {
      return 'N/A';
    }
  }

  String get _bmiCategory {
    if (_bmi == 'N/A') return 'Add weight & height';
    double bmi = double.parse(_bmi);
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal ✅';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    if (_bmi == 'N/A') return hintColor;
    double bmi = double.parse(_bmi);
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: const Text(
          'Profile 👤',
          style: TextStyle(
            color: textColor,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: primaryColor),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF9C94FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          _userName.isEmpty ? 'Your Name' : _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          _userEmail.isEmpty
                              ? 'your@email.com'
                              : _userEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Weight & Height
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _profileInfoItem(
                              '⚖️',
                              _weight.isEmpty ? 'N/A' : '$_weight kg',
                              'Weight',
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white30,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20),
                            ),
                            _profileInfoItem(
                              '📏',
                              _height.isEmpty ? 'N/A' : '$_height cm',
                              'Height',
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white30,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20),
                            ),
                            _profileInfoItem(
                              '💪',
                              _bmi,
                              'BMI',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BMI Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _bmiColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bmiColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.monitor_weight,
                            color: _bmiColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BMI Status',
                              style: TextStyle(
                                color: hintColor,
                                fontFamily: fontFamily,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _bmiCategory,
                              style: TextStyle(
                                color: _bmiColor,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          _bmi,
                          style: TextStyle(
                            color: _bmiColor,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Row
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Statistics',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _statsCard(
                          icon: Icons.fitness_center,
                          value: '$_totalWorkouts',
                          label: 'Workouts',
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statsCard(
                          icon: Icons.directions_walk,
                          value: '$_totalSteps',
                          label: 'Steps',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statsCard(
                          icon: Icons.local_fire_department,
                          value: '$_totalCalories',
                          label: 'Calories',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Settings Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings List
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _settingsTile(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          subtitle: 'Update your information',
                          color: primaryColor,
                          onTap: _editProfile,
                        ),
                        _divider(),
                        _settingsTile(
                          icon: Icons.delete_outline,
                          title: 'Clear Data',
                          subtitle: 'Delete all workout data',
                          color: Colors.orange,
                          onTap: _clearData,
                        ),
                        _divider(),
                        _settingsTile(
                          icon: Icons.logout,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
                          color: Colors.red,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Version
                  const Text(
                    'FitTracker v1.0.0',
                    style: TextStyle(
                      color: hintColor,
                      fontFamily: fontFamily,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Made with ❤️ Flutter',
                    style: TextStyle(
                      color: hintColor,
                      fontFamily: fontFamily,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _profileInfoItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: fontFamily,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _statsCard({
    required IconData icon,
    required String value,
    required String label,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          Text(
            label,
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

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: textColor,
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: hintColor,
          fontFamily: fontFamily,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: hintColor,
        size: 16,
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: hintColor.withOpacity(0.1),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}