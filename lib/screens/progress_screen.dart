import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  Map<String, int> get _workoutCounts {
    Map<String, int> counts = {};
    for (var log in _logs) {
      counts[log.exerciseName] = (counts[log.exerciseName] ?? 0) + 1;
    }
    return counts;
  }

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

  // ── PDF Generation ────────────────────────────────────────

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.day}_${now.month}_${now.year}_${now.hour}_${now.minute}';
    final counts = _workoutCounts;
    final recentLogs = _logs.reversed.take(10).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF7C6DFA), width: 2),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FitTracker',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF7C6DFA),
                    ),
                  ),
                  pw.Text(
                    'Fitness Progress Report',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
              pw.Text(
                'Generated: ${now.day}/${now.month}/${now.year}',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('FitTracker — Personal Fitness Report',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 16),

          // ── Stats Overview Section ────────────────────────
          _pdfSectionTitle('Stats Overview'),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _pdfStatCard('Total Workouts', '${_logs.length}', PdfColors.purple400),
              pw.SizedBox(width: 12),
              _pdfStatCard('Steps Today', '$_steps', PdfColors.blue400),
              pw.SizedBox(width: 12),
              _pdfStatCard('Calories Burned', '$_calories kcal', PdfColors.orange400),
            ],
          ),
          pw.SizedBox(height: 8),

          // Progress bars
          pw.Row(
            children: [
              _pdfProgressBar('Steps Goal', _steps, 10000, PdfColors.blue400),
              pw.SizedBox(width: 12),
              _pdfProgressBar('Calories Goal', _calories, 500, PdfColors.orange400),
            ],
          ),
          pw.SizedBox(height: 24),

          // ── Weekly Activity Section ───────────────────────
          _pdfSectionTitle('Weekly Activity (Last 7 Days)'),
          pw.SizedBox(height: 12),
          _pdfWeeklyTable(),
          pw.SizedBox(height: 24),

          // ── Workout Distribution ──────────────────────────
          if (counts.isNotEmpty) ...[
            _pdfSectionTitle('Workout Distribution'),
            pw.SizedBox(height: 12),
            _pdfDistributionTable(counts),
            pw.SizedBox(height: 24),
          ],

          // ── Recent Activity ───────────────────────────────
          if (recentLogs.isNotEmpty) ...[
            _pdfSectionTitle('Recent Activity (Last 10 Logs)'),
            pw.SizedBox(height: 12),
            _pdfLogsTable(recentLogs),
          ],
        ],
      ),
    );

    // Save the PDF only
    try {
      final bytes = await pdf.save();
      
      // Share/save the PDF (opens system share dialog)
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'FitTracker_Report_$dateStr.pdf',
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFF7C6DFA),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _pdfStatCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1.5),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfProgressBar(String label, int current, int goal, PdfColor color) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final pct = (progress * 100).toInt();
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.Text('$pct%', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: color)),
              ],
            ),
            pw.SizedBox(height: 6),
            // Fixed: Using Container with width instead of FractionallySizedBox
            pw.Container(
              height: 8,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
            pw.SizedBox(height: -8),
            pw.Container(
              height: 8,
              width: progress,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text('$current / $goal',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfWeeklyTable() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final data = _weeklyData;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: days.map((d) => pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(d,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          )).toList(),
        ),
        pw.TableRow(
          children: data.map((v) => pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(v.toInt().toString(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: v > 0
                      ? const PdfColor.fromInt(0xFF7C6DFA)
                      : PdfColors.grey400,
                )),
          )).toList(),
        ),
      ],
    );
  }

  pw.Widget _pdfDistributionTable(Map<String, int> counts) {
    final total = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: ['Exercise', 'Count', 'Share'].map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(h,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          )).toList(),
        ),
        ...entries.map((e) {
          final pct = total > 0 ? ((e.value / total) * 100).toStringAsFixed(1) : '0';
          return pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(e.key, style: const pw.TextStyle(fontSize: 11))),
              pw.Padding(padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('${e.value}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
              pw.Padding(padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('$pct%',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 11))),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfLogsTable(List<WorkoutLog> logs) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: ['Exercise', 'Sets', 'Reps', 'Date'].map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(h,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          )).toList(),
        ),
        ...logs.map((log) => pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8),
                child: pw.Text(log.exerciseName, style: const pw.TextStyle(fontSize: 11))),
            pw.Padding(padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${log.sets}',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 11))),
            pw.Padding(padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${log.reps}',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 11))),
            pw.Padding(padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${log.date.day}/${log.date.month}/${log.date.year}',
                  style: const pw.TextStyle(fontSize: 11),
                )),
          ],
        )),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────

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
          // ── PDF Save Button ──────────────────────────────────
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.green),
            tooltip: 'Save PDF Report',
            onPressed: _isLoading ? null : _generatePdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsOverview(),
                    const SizedBox(height: 24),
                    const Text('📅 Weekly Activity',
                        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: fontFamily)),
                    const SizedBox(height: 16),
                    _buildBarChart(),
                    const SizedBox(height: 24),
                    const Text('📈 Stats Overview',
                        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: fontFamily)),
                    const SizedBox(height: 16),
                    _buildStatsCards(),
                    const SizedBox(height: 24),
                    if (_workoutCounts.isNotEmpty) ...[
                      const Text('🥧 Workout Distribution',
                          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: fontFamily)),
                      const SizedBox(height: 16),
                      _buildPieChart(),
                      const SizedBox(height: 24),
                    ],
                    const Text('🕐 Recent Activity',
                        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: fontFamily)),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 24),

                    // ── Save PDF Button at bottom ───────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _generatePdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.save_alt, color: Colors.white),
                        label: const Text(
                          'Save PDF Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Widget Builders ─────────────────────────────────

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(child: _statCard(title: 'Total\nWorkouts', value: '${_logs.length}', icon: Icons.fitness_center, color: primaryColor)),
        const SizedBox(width: 12),
        Expanded(child: _statCard(title: 'Total\nSteps', value: '$_steps', icon: Icons.directions_walk, color: Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _statCard(title: 'Calories\nBurned', value: '$_calories', icon: Icons.local_fire_department, color: Colors.orange)),
      ],
    );
  }

  Widget _statCard({required String title, required String value, required IconData icon, required Color color}) {
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
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: fontFamily)),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: hintColor, fontSize: 11, fontFamily: fontFamily)),
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
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: weeklyData.reduce((a, b) => a > b ? a : b) + 2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => cardColor,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${rod.toY.toInt()} workouts',
                const TextStyle(color: primaryColor, fontFamily: fontFamily, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(days[value.toInt() % 7],
                    style: const TextStyle(color: hintColor, fontFamily: fontFamily, fontSize: 12)),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                    style: const TextStyle(color: hintColor, fontFamily: fontFamily, fontSize: 11)),
                reservedSize: 28,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: hintColor.withOpacity(0.1), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklyData[index],
                color: primaryColor,
                width: 22,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: weeklyData.reduce((a, b) => a > b ? a : b) + 2,
                  color: primaryColor.withOpacity(0.1),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.directions_walk, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Steps', style: TextStyle(color: textColor, fontFamily: fontFamily, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                Text('$_steps', style: const TextStyle(color: Colors.blue, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: fontFamily)),
                const Text('Goal: 10,000', style: TextStyle(color: hintColor, fontFamily: fontFamily, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_steps / 10000).clamp(0.0, 1.0),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('Calories', style: TextStyle(color: textColor, fontFamily: fontFamily, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                Text('$_calories', style: const TextStyle(color: Colors.orange, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: fontFamily)),
                const Text('Goal: 500 kcal', style: TextStyle(color: hintColor, fontFamily: fontFamily, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_calories / 500).clamp(0.0, 1.0),
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
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
    final colors = [primaryColor, Colors.blue, Colors.orange, Colors.green, Colors.pink, Colors.cyan, Colors.purple];
    final entries = counts.entries.toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: List.generate(entries.length, (index) {
                final color = colors[index % colors.length];
                final value = entries[index].value.toDouble();
                return PieChartSectionData(
                  color: color,
                  value: value,
                  title: '${value.toInt()}',
                  radius: 50,
                  titleStyle: const TextStyle(color: Colors.white, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 14),
                );
              }),
            )),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(entries.length, (index) {
              final color = colors[index % colors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(entries[index].key, style: const TextStyle(color: hintColor, fontFamily: fontFamily, fontSize: 12)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (_logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
        child: const Center(
          child: Text('No activity yet!\nStart logging your workouts.',
              textAlign: TextAlign.center, style: TextStyle(color: hintColor, fontFamily: fontFamily)),
        ),
      );
    }
    final recentLogs = _logs.reversed.take(5).toList();
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentLogs.length,
        separatorBuilder: (context, index) => Divider(color: hintColor.withOpacity(0.1), height: 1),
        itemBuilder: (context, index) {
          final log = recentLogs[index];
          return ListTile(
            leading: Container(
              height: 40, width: 40,
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.fitness_center, color: primaryColor, size: 20),
            ),
            title: Text(log.exerciseName,
                style: const TextStyle(color: textColor, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('${log.sets} Sets × ${log.reps} Reps',
                style: const TextStyle(color: hintColor, fontFamily: fontFamily, fontSize: 12)),
            trailing: Text('${log.date.day}/${log.date.month}',
                style: const TextStyle(color: primaryColor, fontFamily: fontFamily, fontSize: 12)),
          );
        },
      ),
    );
  }
}