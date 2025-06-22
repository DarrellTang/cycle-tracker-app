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
  Profile? _activeProfile;
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
        _activeProfile = activeProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.profileCreate),
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
        // Active profile display
        if (_activeProfile != null)
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _activeProfile!.colorCode != null
                            ? Color(
                                int.parse(
                                  _activeProfile!.colorCode!.replaceFirst(
                                    '#',
                                    '0xFF',
                                  ),
                                ),
                              )
                            : Colors.blue,
                        child: Text(
                          _activeProfile!.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Currently tracking: ${_activeProfile!.name}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Cycle length: ${_activeProfile!.defaultCycleLength} days',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Cycle tracking features coming soon...'),
                ],
              ),
            ),
          ),

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
                onPressed: () => Navigator.pushNamed(context, Routes.profile),
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
              final isActive = profile.id == _activeProfile?.id;
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
                    onTap: isActive
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await _profileService.setActiveProfile(profile.id);
                            _loadProfiles();
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Switched to ${profile.name}'),
                                ),
                              );
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
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
                              if (isActive)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
            onPressed: () => Navigator.pushNamed(context, Routes.profile),
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
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  Routes.profile,
                                ),
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
        onPressed: () => Navigator.pushNamed(context, Routes.profileCreate),
        tooltip: 'Add Profile',
        child: const Icon(Icons.add),
      ),
    );
  }
}
