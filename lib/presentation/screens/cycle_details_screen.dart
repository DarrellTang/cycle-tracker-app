import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';
import 'package:cycle_tracker_app/presentation/screens/period_logging_screen.dart';
import 'package:cycle_tracker_app/core/services/cycle_calculation_service.dart';

/// Screen for displaying cycle details with calendar view
class CycleDetailsScreen extends ConsumerStatefulWidget {
  final Profile? profile;

  const CycleDetailsScreen({super.key, this.profile});

  @override
  ConsumerState<CycleDetailsScreen> createState() => _CycleDetailsScreenState();
}

class _CycleDetailsScreenState extends ConsumerState<CycleDetailsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final CycleCalculationService _cycleCalculationService =
      CycleCalculationService();
  List<CycleRecord> _cycleHistory = [];
  CycleStatistics? _cycleStatistics;

  @override
  void initState() {
    super.initState();
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    if (widget.profile == null) return;

    // TODO: Load actual cycle data from repository
    // For now, create sample data for demonstration
    _cycleHistory = _createSampleCycleData();

    _cycleStatistics = _cycleCalculationService.calculateCycleStatistics(
      widget.profile!,
      _cycleHistory,
    );

    setState(() {});
  }

  List<CycleRecord> _createSampleCycleData() {
    // Create sample cycle data for demonstration
    final now = DateTime.now();
    return [
      CycleRecord(
        id: '1',
        profileId: widget.profile!.id,
        startDate: now.subtract(const Duration(days: 35)),
        endDate: now.subtract(const Duration(days: 31)),
        cycleLength: 28,
        periodLength: 4,
        currentPhase: CyclePhase.menstrual,
        flowIntensity: 3,
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(days: 31)),
      ),
      CycleRecord(
        id: '2',
        profileId: widget.profile!.id,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.subtract(const Duration(days: 3)),
        cycleLength: 28,
        periodLength: 4,
        currentPhase: CyclePhase.menstrual,
        flowIntensity: 2,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.profile != null
              ? "${widget.profile!.name}'s Cycle"
              : 'Cycle Details',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: widget.profile != null
                ? () => _navigateToPeriodLogging()
                : null,
            icon: const Icon(Icons.add_circle),
            tooltip: 'Log Period',
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to cycle settings
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Cycle Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Info Card
            if (widget.profile != null) _buildProfileCard(),

            // Calendar Legend
            _buildCalendarLegend(),

            // Calendar Widget
            Card(
              margin: const EdgeInsets.all(16),
              child: TableCalendar<CycleRecord>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.sunday,

                // Calendar styling
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.pink[600]),
                  holidayTextStyle: TextStyle(color: Colors.pink[600]),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(
                    color: Colors.red[400],
                    shape: BoxShape.circle,
                  ),
                ),

                // Header styling
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                ),

                // Event handling
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showDayDetails(selectedDay);
                },

                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },

                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },

                // Custom builders for different day types
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    return _buildDayMarker(day);
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(day, false, false, false);
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(day, true, false, false);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(day, false, true, false);
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(day, false, false, true);
                  },
                ),
              ),
            ),

            // Phase Information
            _buildPhaseInfo(),

            // Quick Actions
            _buildQuickActions(),

            // Add some bottom padding
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final profile = widget.profile!;
    final profileColor = profile.colorCode != null
        ? Color(int.parse(profile.colorCode!.replaceFirst('#', '0xFF')))
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: profileColor,
              radius: 25,
              child: Text(
                profile.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Cycle: ${profile.defaultCycleLength} days',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Period: ${profile.defaultPeriodLength} days',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(
    DateTime day,
    bool isSelected,
    bool isToday,
    bool isOutside,
  ) {
    final phase = _getPhaseForDay(day);
    final isPeriod = _isPeriodDay(day);
    final isPredicatedPeriod = _isPredictedPeriodDay(day);
    final fertilityWindow = widget.profile != null
        ? _cycleCalculationService.calculateFertilityWindow(
            day,
            widget.profile!,
            _cycleHistory,
          )
        : null;
    final isFertile = fertilityWindow?.isCurrentlyFertile ?? false;

    Color? backgroundColor;
    Color? textColor;
    Border? border;

    if (isOutside) {
      backgroundColor = Colors.grey[100];
      textColor = Colors.grey[400];
    } else if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = Theme.of(context).primaryColor.withValues(alpha: 0.3);
      textColor = Colors.white;
    } else {
      backgroundColor = _getPhaseColor(phase).withValues(alpha: 0.3);
      textColor = Colors.black87;
    }

    // Period day styling
    if (isPeriod) {
      border = Border.all(color: Colors.red, width: 2);
      if (!isSelected && !isToday) {
        backgroundColor = Colors.red[400];
        textColor = Colors.white;
      }
    } else if (isPredicatedPeriod) {
      border = Border.all(
        color: Colors.red[300]!,
        width: 2,
        style: BorderStyle.solid,
      );
    }

    // Fertility window styling
    if (isFertile && !isPeriod && !isPredicatedPeriod) {
      border = Border.all(color: Colors.orange, width: 2);
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: border,
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isPeriod || isFertile
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          // Additional indicators
          if (isFertile && !isPeriod)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (isPredicatedPeriod)
            Positioned(
              bottom: 2,
              left: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.red[300],
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayMarker(DateTime day) {
    if (_isPeriodDay(day)) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCalendarLegend() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar Legend',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem(
                  Colors.red[400]!,
                  'Period',
                  hasRedBorder: true,
                ),
                _buildLegendItem(
                  Colors.red[300]!,
                  'Predicted',
                  hasDashedBorder: true,
                ),
                _buildLegendItem(
                  Colors.orange,
                  'Fertile',
                  hasOrangeBorder: true,
                ),
                _buildLegendItem(Colors.green[300]!, 'Follicular'),
                _buildLegendItem(Colors.orange[300]!, 'Ovulation'),
                _buildLegendItem(Colors.purple[300]!, 'Luteal'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label, {
    bool hasRedBorder = false,
    bool hasDashedBorder = false,
    bool hasOrangeBorder = false,
  }) {
    Border? border;
    if (hasRedBorder) {
      border = Border.all(color: Colors.red, width: 2);
    } else if (hasDashedBorder) {
      border = Border.all(color: Colors.red[300]!, width: 2);
    } else if (hasOrangeBorder) {
      border = Border.all(color: Colors.orange, width: 2);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: border,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildPhaseInfo() {
    final currentPhase = _getCurrentPhase();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Phase',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getPhaseColor(currentPhase),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currentPhase.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              currentPhase.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _getPhaseAdvice(currentPhase),
              style: Theme.of(context).textTheme.bodySmall,
            ),

            // Cycle Statistics
            if (_cycleStatistics != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Cycle Statistics',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    'Avg Cycle',
                    '${_cycleStatistics!.averageCycleLength} days',
                  ),
                  _buildStatItem(
                    'Avg Period',
                    '${_cycleStatistics!.averagePeriodLength} days',
                  ),
                  _buildStatItem(
                    'Total Cycles',
                    '${_cycleStatistics!.totalCycles}',
                  ),
                ],
              ),
              if (_cycleStatistics!.nextPredictedPeriod != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Next predicted period: ${_formatDate(_cycleStatistics!.nextPredictedPeriod!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: widget.profile != null
                ? () => _navigateToPeriodLogging()
                : null,
            icon: const Icon(Icons.water_drop),
            label: const Text('Log Period'),
          ),
          ElevatedButton.icon(
            onPressed: () => _showSymptomLoggingDialog(),
            icon: const Icon(Icons.mood),
            label: const Text('Log Symptoms'),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCycleHistory(),
            icon: const Icon(Icons.timeline),
            label: const Text('History'),
          ),
        ],
      ),
    );
  }

  // Helper methods for phase and period calculation
  CyclePhase _getPhaseForDay(DateTime day) {
    if (widget.profile == null) return CyclePhase.follicular;

    return _cycleCalculationService.calculatePhaseForDate(
      day,
      widget.profile!,
      _cycleHistory,
    );
  }

  CyclePhase _getCurrentPhase() {
    return _getPhaseForDay(DateTime.now());
  }

  bool _isPeriodDay(DateTime day) {
    if (widget.profile == null) return false;

    return _cycleCalculationService.isPeriodDay(
      day,
      widget.profile!,
      _cycleHistory,
    );
  }

  bool _isPredictedPeriodDay(DateTime day) {
    if (widget.profile == null) return false;

    // Check if day falls within predicted future periods
    final predictions = _cycleCalculationService.predictFuturePeriods(
      widget.profile!,
      _cycleHistory,
      3, // 3 months ahead
    );

    for (final predictedDate in predictions) {
      // Check if date falls within predicted period duration
      for (int i = 0; i < widget.profile!.defaultPeriodLength; i++) {
        final periodDay = predictedDate.add(Duration(days: i));
        if (_isSameDay(day, periodDay)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Color _getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return Colors.red[300]!;
      case CyclePhase.follicular:
        return Colors.green[300]!;
      case CyclePhase.ovulation:
        return Colors.orange[300]!;
      case CyclePhase.luteal:
        return Colors.purple[300]!;
    }
  }

  String _getPhaseAdvice(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Rest and self-care are important. Stay hydrated and consider gentle movement.';
      case CyclePhase.follicular:
        return 'Energy levels may be increasing. Good time for new projects and social activities.';
      case CyclePhase.ovulation:
        return 'Peak energy and fertility. Great time for important conversations and decisions.';
      case CyclePhase.luteal:
        return 'Energy may be decreasing. Focus on completing tasks and preparing for rest.';
    }
  }

  // Dialog methods
  void _showDayDetails(DateTime day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${day.day}/${day.month}/${day.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase: ${_getPhaseForDay(day).displayName}'),
            if (_isPeriodDay(day)) const Text('Period Day'),
            const SizedBox(height: 8),
            const Text('No additional data logged for this day.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.profile != null) {
                _navigateToPeriodLogging(selectedDate: day);
              }
            },
            child: const Text('Log Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPeriodLogging({DateTime? selectedDate}) async {
    if (widget.profile == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PeriodLoggingScreen(
          profile: widget.profile!,
          selectedDate: selectedDate ?? _selectedDay,
        ),
      ),
    );

    if (result == true) {
      // TODO: Refresh calendar data
      setState(() {
        // Data was saved, refresh the calendar view
      });
    }
  }

  void _showSymptomLoggingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Symptoms'),
        content: const Text(
          'Symptom logging will be implemented in a future task.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCycleHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cycle History'),
        content: const Text(
          'Cycle history visualization will be implemented in subtask 4.5.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
