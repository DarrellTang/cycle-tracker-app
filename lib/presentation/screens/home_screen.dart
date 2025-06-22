import 'package:flutter/foundation.dart';
import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/core/router.dart';
import 'package:cycle_tracker_app/core/services/profile_service.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';

/// Home screen displaying family member profiles and cycle overview
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ProfileService _profileService = ProfileService();
  List<Profile> _profiles = [];
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

      if (mounted) {
        setState(() {
          _profiles = profiles;
          _isLoading = false;
        });
        
        // Show web storage notice once
        if (kIsWeb && _profiles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Web version: Data stored temporarily in browser session'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profiles = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildProfileOverview() {
    if (_profiles.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                'Create your first profile to start tracking cycles',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, Routes.profileCreate);
                  if (result == true) {
                    _loadProfiles(); // Refresh the profile list
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create First Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Profile management section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profiles (${_profiles.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, Routes.profile);
                  _loadProfiles(); // Refresh after returning from profile management
                },
                child: const Text('Manage All'),
              ),
            ],
          ),
        ),

        // Quick profile list
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _profiles.length,
            itemBuilder: (context, index) {
              final profile = _profiles[index];
              final profileColor = profile.colorCode != null
                  ? Color(
                      int.parse(profile.colorCode!.replaceFirst('#', '0xFF')),
                    )
                  : Colors.blue;

              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // Navigate to cycle details for this profile
                      Navigator.pushNamed(
                        context, 
                        Routes.cycleDetails,
                        arguments: profile,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: profileColor,
                            child: Text(
                              profile.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, Routes.profile);
              _loadProfiles(); // Refresh after returning from profile management
            },
            icon: const Icon(Icons.people),
            tooltip: 'Manage Profiles',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfiles,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileOverview(),

                    const SizedBox(height: 32),

                    // Navigation buttons for development/testing
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Development Navigation:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(context, Routes.profile);
                                  _loadProfiles(); // Refresh after returning from profile management
                                },
                                child: const Text('Manage Profiles'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  Routes.cycleDetails,
                                ),
                                child: const Text('Cycle Details'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  Routes.settings,
                                ),
                                child: const Text('Settings'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, Routes.profileCreate);
          if (result == true) {
            _loadProfiles(); // Refresh the profile list
          }
        },
        tooltip: 'Add Profile',
        child: const Icon(Icons.add),
      ),
    );
  }
}
