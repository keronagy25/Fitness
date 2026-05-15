import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService _apiService = ApiService();
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String _status = 'Press button to test API';

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _status = '⏳ Fetching data from API...';
    });

    try {
      final exercises = await _apiService.fetchExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
        _status = '✅ API Working! Found ${exercises.length} exercises';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ API Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: const Text(
          'API Test 🧪',
          style: TextStyle(
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // API URL Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌐 API Endpoint:',
                    style: TextStyle(
                      color: primaryColor,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'https://jsonplaceholder.typicode.com/posts?_limit=20',
                    style: TextStyle(
                      color: hintColor,
                      fontFamily: fontFamily,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _status.contains('✅')
                      ? Colors.green
                      : _status.contains('❌')
                          ? Colors.red
                          : primaryColor,
                ),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  color: _status.contains('✅')
                      ? Colors.green
                      : _status.contains('❌')
                          ? Colors.red
                          : textColor,
                  fontFamily: fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Test Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testApi,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.wifi, color: Colors.white),
                label: Text(
                  _isLoading ? 'Testing...' : 'Test API Now',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _exercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_download,
                            color: hintColor,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No data yet\nPress Test API button',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: hintColor,
                              fontFamily: fontFamily,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _exercises[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // Index Circle
                              CircleAvatar(
                                backgroundColor: primaryColor,
                                radius: 20,
                                child: Text(
                                  '${exercise.id}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: fontFamily,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Exercise Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        color: textColor,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      exercise.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: hintColor,
                                        fontFamily: fontFamily,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  exercise.category,
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontFamily: fontFamily,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}