import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/core/services/profile_service.dart';
import 'package:cycle_tracker_app/presentation/widgets/color_picker_widget.dart';

/// Screen for creating and editing profiles
class ProfileEditScreen extends StatefulWidget {
  final Profile? profile;

  const ProfileEditScreen({super.key, this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _cycleLengthController;
  late TextEditingController _periodLengthController;

  DateTime? _birthDate;
  String? _photoPath;
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  bool get _isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profile = widget.profile;

    _nameController = TextEditingController(text: profile?.name ?? '');
    _cycleLengthController = TextEditingController(
      text: profile?.defaultCycleLength.toString() ?? '28',
    );
    _periodLengthController = TextEditingController(
      text: profile?.defaultPeriodLength.toString() ?? '5',
    );

    _birthDate = profile?.birthDate;
    _photoPath = profile?.photoPath;

    if (profile?.colorCode != null) {
      try {
        _selectedColor = Color(
          int.parse(profile!.colorCode!.replaceFirst('#', '0xFF')),
        );
      } catch (e) {
        _selectedColor = Colors.blue;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select birth date',
    );

    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
      });
    }
  }

  Future<void> _selectColor() async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerWidget(initialColor: _selectedColor),
    );

    if (color != null) {
      setState(() {
        _selectedColor = color;
      });
    }
  }

  Future<void> _selectPhoto() async {
    // For now, show a placeholder dialog
    // In a real app, this would integrate with image_picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Selection'),
        content: const Text(
          'Photo selection will be implemented in a future update. '
          'For now, profiles will use the first letter of the name.',
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateCycleLength(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cycle length is required';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Must be a valid number';
    }
    if (intValue < 21 || intValue > 35) {
      return 'Cycle length must be between 21-35 days';
    }
    return null;
  }

  String? _validatePeriodLength(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Period length is required';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Must be a valid number';
    }
    if (intValue < 3 || intValue > 10) {
      return 'Period length must be between 3-10 days';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final colorCode = _colorToHex(_selectedColor);

      if (_isEditing) {
        // Update existing profile with timeout
        final updatedProfile = widget.profile!.copyWith(
          name: _nameController.text.trim(),
          birthDate: _birthDate,
          photoPath: _photoPath,
          colorCode: colorCode,
          defaultCycleLength: int.parse(_cycleLengthController.text),
          defaultPeriodLength: int.parse(_periodLengthController.text),
          updatedAt: DateTime.now(),
        );

        await _profileService.updateProfile(updatedProfile).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Profile update timed out'),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else {
        // Create new profile with timeout
        await _profileService.createProfile(
          name: _nameController.text.trim(),
          birthDate: _birthDate,
          photoPath: _photoPath,
          colorCode: colorCode,
          defaultCycleLength: int.parse(_cycleLengthController.text),
          defaultPeriodLength: int.parse(_periodLengthController.text),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Profile creation timed out - database may not be ready'),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile created successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      dev.log('Profile save error: $e', name: 'ProfileEditScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _colorToHex(Color color) {
    // Use non-deprecated RGB component accessors
    final r = ((color.r * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final g = ((color.g * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final b = ((color.b * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    return '#$r$g$b';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Create Profile'),
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
              onPressed: _saveProfile,
              child: Text(
                _isEditing ? 'Update' : 'Create',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Photo Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _selectPhoto,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: _selectedColor,
                      backgroundImage:
                          _photoPath != null && _photoPath!.isNotEmpty
                          ? AssetImage(_photoPath!)
                          : null,
                      child: _photoPath == null || _photoPath!.isEmpty
                          ? Text(
                              _nameController.text.isNotEmpty
                                  ? _nameController.text[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _selectPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Change Photo'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'Enter full name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: _validateName,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                setState(() {}); // Rebuild to update avatar
              },
            ),

            const SizedBox(height: 16),

            // Birth Date Field
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  hintText: 'Select birth date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _birthDate != null
                      ? _formatDate(_birthDate!)
                      : 'Not selected',
                  style: _birthDate != null
                      ? null
                      : TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Color Selection
            InkWell(
              onTap: _selectColor,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Profile Color',
                  hintText: 'Choose a color',
                  prefixIcon: Icon(Icons.palette),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Tap to change color'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cycle Settings Section
            Text(
              'Cycle Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cycleLengthController,
                    decoration: const InputDecoration(
                      labelText: 'Cycle Length *',
                      hintText: '28',
                      suffixText: 'days',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateCycleLength,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextFormField(
                    controller: _periodLengthController,
                    decoration: const InputDecoration(
                      labelText: 'Period Length *',
                      hintText: '5',
                      suffixText: 'days',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validatePeriodLength,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Help Text
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Cycle Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Cycle length: Time from first day of period to first day of next period\n'
                      '• Period length: Number of days of menstrual flow\n'
                      '• These can be adjusted later based on tracking data',
                      style: TextStyle(color: Colors.blue[700]),
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
}
