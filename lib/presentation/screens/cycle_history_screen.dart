import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';
import 'package:cycle_tracker_app/core/services/cycle_calculation_service.dart';

/// Screen for displaying comprehensive cycle history and statistics
class CycleHistoryScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const CycleHistoryScreen({super.key, required this.profile});

  @override
  ConsumerState<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends ConsumerState<CycleHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CycleCalculationService _cycleCalculationService =
      CycleCalculationService();
  List<CycleRecord> _cycleHistory = [];
  CycleStatistics? _cycleStatistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCycleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCycleData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load actual cycle data from repository
      // For now, create more comprehensive sample data
      _cycleHistory = _createExtendedSampleData();

      _cycleStatistics = _cycleCalculationService.calculateCycleStatistics(
        widget.profile,
        _cycleHistory,
      );
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<CycleRecord> _createExtendedSampleData() {
    final now = DateTime.now();
    final cycles = <CycleRecord>[];

    // Create 12 months of sample data
    for (int i = 0; i < 12; i++) {
      final startDate = now.subtract(Duration(days: (i * 28) + (i * 2)));
      final cycleLength = 26 + (i % 6); // Vary between 26-31 days
      final periodLength = 3 + (i % 3); // Vary between 3-5 days

      cycles.add(CycleRecord(
        id: 'cycle_$i',
        profileId: widget.profile.id,
        startDate: startDate,
        endDate: startDate.add(Duration(days: periodLength - 1)),
        cycleLength: cycleLength,
        periodLength: periodLength,
        currentPhase: CyclePhase.menstrual,
        flowIntensity: 2 + (i % 3), // Vary between 2-4
        createdAt: startDate,
        updatedAt: startDate.add(Duration(days: periodLength)),
        symptoms: _generateSampleSymptoms(i),
        notes: i % 3 == 0 ? 'Sample notes for cycle ${i + 1}' : null,
      ));
    }

    return cycles.reversed.toList(); // Most recent first
  }

  List<String> _generateSampleSymptoms(int cycleIndex) {
    final allSymptoms = [
      'Cramps',
      'Headache',
      'Bloating',
      'Mood changes',
      'Fatigue',
      'Backache',
      'Breast tenderness',
      'Nausea'
    ];

    // Vary symptoms per cycle
    final symptomCount = 2 + (cycleIndex % 3);
    return allSymptoms.take(symptomCount).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.profile.name}'s Cycle History"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'Charts'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
            Tab(icon: Icon(Icons.list), text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChartsTab(),
                _buildStatisticsTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cycle Length Chart
          _buildChartCard(
            'Cycle Length Trends',
            'Track how your cycle length varies over time',
            _buildCycleLengthChart(),
          ),

          const SizedBox(height: 16),

          // Period Length Chart
          _buildChartCard(
            'Period Length Trends',
            'Monitor changes in period duration',
            _buildPeriodLengthChart(),
          ),

          const SizedBox(height: 16),

          // Flow Intensity Chart
          _buildChartCard(
            'Flow Intensity Patterns',
            'Visualize flow intensity variations',
            _buildFlowIntensityChart(),
          ),

          const SizedBox(height: 16),

          // Symptoms Frequency Chart
          _buildChartCard(
            'Symptom Frequency',
            'Most common symptoms across cycles',
            _buildSymptomsChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, String description, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleLengthChart() {
    if (_cycleHistory.isEmpty) {
      return const Center(child: Text('No cycle data available'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _cycleHistory.length; i++) {
      final cycle = _cycleHistory[i];
      if (cycle.cycleLength != null) {
        spots.add(FlSpot(i.toDouble(), cycle.cycleLength!.toDouble()));
      }
    }

    if (spots.isEmpty) {
      return const Center(child: Text('No cycle length data available'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < _cycleHistory.length) {
                  return Text(
                    '${_cycleHistory.length - value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 20,
        maxY: 35,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodLengthChart() {
    if (_cycleHistory.isEmpty) {
      return const Center(child: Text('No period data available'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _cycleHistory.length; i++) {
      final cycle = _cycleHistory[i];
      if (cycle.periodLength != null) {
        spots.add(FlSpot(i.toDouble(), cycle.periodLength!.toDouble()));
      }
    }

    if (spots.isEmpty) {
      return const Center(child: Text('No period length data available'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < _cycleHistory.length) {
                  return Text(
                    '${_cycleHistory.length - value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 2,
        maxY: 7,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowIntensityChart() {
    if (_cycleHistory.isEmpty) {
      return const Center(child: Text('No flow data available'));
    }

    final intensityData = <String, int>{};
    for (final cycle in _cycleHistory) {
      if (cycle.flowIntensity != null) {
        final label = _getFlowIntensityLabel(cycle.flowIntensity!);
        intensityData[label] = (intensityData[label] ?? 0) + 1;
      }
    }

    if (intensityData.isEmpty) {
      return const Center(child: Text('No flow intensity data available'));
    }

    final sections = intensityData.entries.map((entry) {
      final index = intensityData.keys.toList().indexOf(entry.key);
      final colors = [
        Colors.lightBlue,
        Colors.blue,
        Colors.orange,
        Colors.deepOrange,
        Colors.red,
      ];

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: intensityData.entries.map((entry) {
              final index = intensityData.keys.toList().indexOf(entry.key);
              final colors = [
                Colors.lightBlue,
                Colors.blue,
                Colors.orange,
                Colors.deepOrange,
                Colors.red,
              ];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: colors[index % colors.length],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsChart() {
    if (_cycleHistory.isEmpty) {
      return const Center(child: Text('No symptom data available'));
    }

    final symptomCounts = <String, int>{};
    for (final cycle in _cycleHistory) {
      if (cycle.symptoms != null) {
        for (final symptom in cycle.symptoms!) {
          symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
        }
      }
    }

    if (symptomCounts.isEmpty) {
      return const Center(child: Text('No symptom data available'));
    }

    // Get top 6 most common symptoms
    final topSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(6);

    final barGroups = topSymptoms.map((entry) {
      final index = topSymptoms.toList().indexOf(entry);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.purple,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (symptomCounts.values
                .reduce((a, b) => a > b ? a : b)
                .toDouble() *
            1.2),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < topSymptoms.length) {
                  final symptom = topSymptoms.toList()[value.toInt()].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      symptom,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_cycleStatistics == null) {
      return const Center(child: Text('No statistics available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overview Statistics
          _buildStatisticsCard(
            'Cycle Overview',
            [
              _buildStatRow('Total Cycles Tracked',
                  '${_cycleStatistics!.totalCycles}'),
              _buildStatRow('Average Cycle Length',
                  '${_cycleStatistics!.averageCycleLength} days'),
              _buildStatRow('Average Period Length',
                  '${_cycleStatistics!.averagePeriodLength} days'),
              _buildStatRow('Cycle Variability',
                  '${_cycleStatistics!.cycleVariability.toStringAsFixed(1)} days'),
            ],
          ),

          const SizedBox(height: 16),

          // Predictions
          _buildStatisticsCard(
            'Predictions',
            [
              if (_cycleStatistics!.lastPeriodDate != null)
                _buildStatRow('Last Period',
                    _formatDate(_cycleStatistics!.lastPeriodDate!)),
              if (_cycleStatistics!.nextPredictedPeriod != null)
                _buildStatRow('Next Predicted Period',
                    _formatDate(_cycleStatistics!.nextPredictedPeriod!)),
              _buildStatRow(
                  'Days Until Next Period', _getDaysUntilNextPeriod()),
            ],
          ),

          const SizedBox(height: 16),

          // Flow Patterns
          _buildFlowStatistics(),

          const SizedBox(height: 16),

          // Symptom Analysis
          _buildSymptomStatistics(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStatistics() {
    final flowCounts = <String, int>{};
    double totalIntensity = 0;
    int intensityCount = 0;

    for (final cycle in _cycleHistory) {
      if (cycle.flowIntensity != null) {
        final label = _getFlowIntensityLabel(cycle.flowIntensity!);
        flowCounts[label] = (flowCounts[label] ?? 0) + 1;
        totalIntensity += cycle.flowIntensity!;
        intensityCount++;
      }
    }

    final avgIntensity = intensityCount > 0
        ? (totalIntensity / intensityCount).toStringAsFixed(1)
        : 'N/A';

    final mostCommonFlow = flowCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return _buildStatisticsCard(
      'Flow Patterns',
      [
        _buildStatRow('Average Flow Intensity', avgIntensity),
        _buildStatRow('Most Common Flow', mostCommonFlow),
        const SizedBox(height: 8),
        ...flowCounts.entries.map((entry) =>
            _buildStatRow('${entry.key} Flow', '${entry.value} cycles')),
      ],
    );
  }

  Widget _buildSymptomStatistics() {
    final symptomCounts = <String, int>{};
    for (final cycle in _cycleHistory) {
      if (cycle.symptoms != null) {
        for (final symptom in cycle.symptoms!) {
          symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
        }
      }
    }

    if (symptomCounts.isEmpty) {
      return _buildStatisticsCard(
        'Symptom Analysis',
        [const Text('No symptom data available')],
      );
    }

    final topSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

    return _buildStatisticsCard(
      'Top Symptoms',
      topSymptoms
          .map((entry) => _buildStatRow(
              entry.key, '${entry.value}/${_cycleHistory.length} cycles'))
          .toList(),
    );
  }

  Widget _buildHistoryTab() {
    if (_cycleHistory.isEmpty) {
      return const Center(child: Text('No cycle history available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cycleHistory.length,
      itemBuilder: (context, index) {
        final cycle = _cycleHistory[index];
        return _buildCycleHistoryCard(cycle, index);
      },
    );
  }

  Widget _buildCycleHistoryCard(CycleRecord cycle, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          'Cycle ${_cycleHistory.length - index}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_formatDate(cycle.startDate)} - ${cycle.endDate != null ? _formatDate(cycle.endDate!) : "Ongoing"}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCycleDetail(
                        'Cycle Length', '${cycle.cycleLength ?? "N/A"} days'),
                    _buildCycleDetail(
                        'Period Length', '${cycle.periodLength ?? "N/A"} days'),
                    _buildCycleDetail('Flow Intensity',
                        _getFlowIntensityLabel(cycle.flowIntensity ?? 3)),
                  ],
                ),
                if (cycle.symptoms != null && cycle.symptoms!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Symptoms:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: cycle.symptoms!
                        .map((symptom) => Chip(
                              label: Text(symptom),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
                if (cycle.notes != null && cycle.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Notes:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(cycle.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getFlowIntensityLabel(int intensity) {
    switch (intensity) {
      case 1:
        return 'Spotting';
      case 2:
        return 'Light';
      case 3:
        return 'Normal';
      case 4:
        return 'Heavy';
      case 5:
        return 'Very Heavy';
      default:
        return 'Normal';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDaysUntilNextPeriod() {
    if (_cycleStatistics?.nextPredictedPeriod == null) return 'N/A';

    final now = DateTime.now();
    final nextPeriod = _cycleStatistics!.nextPredictedPeriod!;
    final difference = nextPeriod.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue by ${difference.abs()} days';
    } else if (difference == 0) {
      return 'Today';
    } else {
      return '$difference days';
    }
  }
}