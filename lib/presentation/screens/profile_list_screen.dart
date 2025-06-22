import 'package:flutter/material.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/core/services/profile_service.dart';
import 'package:cycle_tracker_app/presentation/screens/profile_edit_screen.dart';

/// Screen displaying all profiles with management options
class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  final ProfileService _profileService = ProfileService();
  List<Profile> _profiles = [];
  String? _activeProfileId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final profiles = await _profileService.getAllProfiles();
      final activeProfile = await _profileService.getActiveProfile();

      setState(() {
        _profiles = profiles;
        _activeProfileId = activeProfile?.id;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profiles: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setActiveProfile(String profileId) async {
    try {
      await _profileService.setActiveProfile(profileId);
      setState(() => _activeProfileId = profileId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile activated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error activating profile: $e')));
      }
    }
  }

  Future<void> _deleteProfile(Profile profile) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Profile'),
          content: Text(
            'Are you sure you want to delete ${profile.name}\'s profile? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _profileService.deleteProfile(profile.id);
        await _loadProfiles();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting profile: $e')));
        }
      }
    }
  }

  Future<void> _navigateToEditProfile([Profile? profile]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(profile: profile),
      ),
    );

    if (result == true) {
      _loadProfiles();
    }
  }

  Widget _buildProfileCard(Profile profile) {
    final isActive = profile.id == _activeProfileId;
    final profileColor = profile.colorCode != null
        ? Color(int.parse(profile.colorCode!.replaceFirst('#', '0xFF')))
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: profileColor,
          backgroundImage:
              profile.photoPath != null && profile.photoPath!.isNotEmpty
              ? AssetImage(profile.photoPath!)
              : null,
          child: profile.photoPath == null || profile.photoPath!.isEmpty
              ? Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          profile.name,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile.birthDate != null)
              Text(
                'Born: ${_formatDate(profile.birthDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            Text(
              'Cycle: ${profile.defaultCycleLength} days',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () => _setActiveProfile(profile.id),
                child: const Text('Activate'),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _navigateToEditProfile(profile);
                    break;
                  case 'delete':
                    _deleteProfile(profile);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No profiles yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first profile to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToEditProfile(),
            icon: const Icon(Icons.add),
            label: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadProfiles,
              child: ListView.builder(
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  return _buildProfileCard(_profiles[index]);
                },
              ),
            ),
      floatingActionButton: _profiles.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _navigateToEditProfile(),
              tooltip: 'Add Profile',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
