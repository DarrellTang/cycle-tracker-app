import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';

/// Screen for logging period information
class PeriodLoggingScreen extends ConsumerStatefulWidget {
  final Profile profile;
  final DateTime? selectedDate;

  const PeriodLoggingScreen({
    super.key,
    required this.profile,
    this.selectedDate,
  });

  @override
  ConsumerState<PeriodLoggingScreen> createState() =>
      _PeriodLoggingScreenState();
}

class _PeriodLoggingScreenState extends ConsumerState<PeriodLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int _flowIntensity = 3; // 1-5 scale
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.profile.name}'s Period"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _savePeriodData,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Period Dates Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period Dates',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Date
                    InkWell(
                      onTap: () => _selectStartDate(),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date *',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startDate != null
                              ? _formatDate(_startDate!)
                              : 'Select start date',
                          style: _startDate != null
                              ? null
                              : TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // End Date
                    InkWell(
                      onTap: () => _selectEndDate(),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date (Optional)',
                          prefixIcon: Icon(Icons.event_available),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate != null
                              ? _formatDate(_endDate!)
                              : 'Select end date',
                          style: _endDate != null
                              ? null
                              : TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),

                    if (_endDate != null && _startDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Duration: ${_endDate!.difference(_startDate!).inDays + 1} days',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blue[700]),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Flow Intensity Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flow Intensity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      _getFlowIntensityDescription(_flowIntensity),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    Slider(
                      value: _flowIntensity.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _getFlowIntensityLabel(_flowIntensity),
                      onChanged: (value) {
                        setState(() {
                          _flowIntensity = value.round();
                        });
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Light',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Heavy',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Any symptoms, observations, or notes...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Symptoms Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Common Symptoms',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add to notes',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSymptomChip('Cramps'),
                        _buildSymptomChip('Headache'),
                        _buildSymptomChip('Bloating'),
                        _buildSymptomChip('Mood changes'),
                        _buildSymptomChip('Fatigue'),
                        _buildSymptomChip('Backache'),
                        _buildSymptomChip('Breast tenderness'),
                        _buildSymptomChip('Nausea'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomChip(String symptom) {
    return ActionChip(
      label: Text(symptom),
      onPressed: () {
        final currentText = _notesController.text;
        String newText = currentText;

        if (currentText.isNotEmpty &&
            !currentText.endsWith(' ') &&
            !currentText.endsWith(',')) {
          newText += ', ';
        }
        newText += symptom.toLowerCase();

        _notesController.text = newText;

        // Show a brief visual feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "$symptom" to notes'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  String _getFlowIntensityDescription(int intensity) {
    switch (intensity) {
      case 1:
        return 'Spotting - Very light bleeding, may be brown or pink';
      case 2:
        return 'Light flow - Minimal bleeding, light protection needed';
      case 3:
        return 'Normal flow - Regular bleeding, standard protection';
      case 4:
        return 'Heavy flow - Substantial bleeding, frequent changes needed';
      case 5:
        return 'Very heavy flow - Excessive bleeding, may interfere with daily activities';
      default:
        return 'Normal flow - Regular bleeding, standard protection';
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Select period start date',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 4)),
      firstDate: _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Select period end date',
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _savePeriodData() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual data saving to repository
      // For now, simulate saving
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Period data saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Return success result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving period data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
