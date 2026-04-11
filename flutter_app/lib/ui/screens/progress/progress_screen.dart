import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/providers/progress_provider.dart';
import '../../../data/models/progress_model.dart';

/// Progress screen with charts for weight, steps, calories over time
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String _range = 'week';
  bool _showLogDialog = false;

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(progressRangeProvider(_range));
    final weightAsync = ref.watch(weightHistoryProvider(_range));
    final todayAsync = ref.watch(todayProgressProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart, color: AppTheme.primaryColor),
            onPressed: () => _showLogProgressDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () async {
          ref.invalidate(progressRangeProvider(_range));
          ref.invalidate(weightHistoryProvider(_range));
          ref.invalidate(todayProgressProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Range selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['week', 'month', 'year'].map((r) {
                  final isSelected = _range == r;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _range = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            r[0].toUpperCase() + r.substring(1),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.darkTextMuted,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            // Today's stats
            todayAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (log) => _TodayStatsCard(log: log),
            ),

            const SizedBox(height: 20),

            // Weight chart
            weightAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (e, _) => _EmptyChart(label: 'Weight History', message: 'Log daily weight to see trends'),
              data: (data) => data.isEmpty
                  ? _EmptyChart(label: 'Weight History', message: 'Log daily weight to see chart')
                  : _WeightChart(data: data),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 20),

            // Steps chart
            progressAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (e, _) => _EmptyChart(label: 'Steps History', message: 'Log daily steps to see trends'),
              data: (logs) => logs.isEmpty
                  ? _EmptyChart(label: 'Steps History', message: 'Start logging daily steps')
                  : _StepsChart(logs: logs),
            ).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 20),

            // Body measurements
            _MeasurementsCard(
              onLogTap: () => _showLogProgressDialog(context),
            ).animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showLogProgressDialog(BuildContext context) {
    final stepsCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final waterCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Today\'s Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
            const SizedBox(height: 20),
            _quickField('Steps', stepsCtrl, Icons.directions_walk, AppTheme.accentColor),
            const SizedBox(height: 12),
            _quickField('Weight (kg)', weightCtrl, Icons.monitor_weight_outlined, AppTheme.accentGreen),
            const SizedBox(height: 12),
            _quickField('Water (ml)', waterCtrl, Icons.water_drop_outlined, AppTheme.primaryColor),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final data = {
                    if (stepsCtrl.text.isNotEmpty) 'steps': int.tryParse(stepsCtrl.text),
                    if (weightCtrl.text.isNotEmpty) 'weight': double.tryParse(weightCtrl.text),
                    if (waterCtrl.text.isNotEmpty) 'waterIntake': int.tryParse(waterCtrl.text),
                  };
                  await ref.read(progressLogNotifierProvider.notifier).logProgress(data);
                  ref.invalidate(todayProgressProvider);
                  ref.invalidate(progressRangeProvider(_range));
                  ref.invalidate(weightHistoryProvider(_range));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickField(String label, TextEditingController ctrl, IconData icon, Color color) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppTheme.darkText),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: color),
      ),
    );
  }
}

class _TodayStatsCard extends StatelessWidget {
  final ProgressLogModel? log;
  const _TodayStatsCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat('Steps', '${log?.steps ?? 0}', Icons.directions_walk, AppTheme.accentColor),
              _Stat('Weight', log?.weight != null ? '${log!.weight}kg' : '-', Icons.monitor_weight_outlined, AppTheme.accentGreen),
              _Stat('Water', log?.waterIntake != null ? '${log!.waterIntake}ml' : '-', Icons.water_drop_outlined, AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _WeightChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries
        .where((e) => e.value['weight'] != null)
        .map((e) => FlSpot(e.key.toDouble(), (e.value['weight'] as num).toDouble()))
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weight Trend', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.darkBorder, strokeWidth: 1),
                  getDrawingVerticalLine: (v) => FlLine(color: AppTheme.darkBorder, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}',
                          style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 10)),
                      reservedSize: 36,
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.accentGreen,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentGreen.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsChart extends StatelessWidget {
  final List<ProgressLogModel> logs;
  const _StepsChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Steps History', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.darkBorder, strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) => Text('${(v / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 10)),
                      reservedSize: 30,
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: logs.take(14).toList().asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.steps.toDouble(),
                        color: AppTheme.accentColor,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 10000,
                          color: AppTheme.accentColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementsCard extends StatelessWidget {
  final VoidCallback onLogTap;
  const _MeasurementsCard({required this.onLogTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Body Measurements', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: onLogTap, child: const Text('Log')),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ['Chest', 'Waist', 'Hips', 'Bicep', 'Thigh'].map((m) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    Text('-', style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold)),
                    Text(m, style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String label, message;
  const _EmptyChart({required this.label, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart, color: AppTheme.darkBorder, size: 40),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500)),
            Text(message, style: TextStyle(color: AppTheme.darkTextMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
