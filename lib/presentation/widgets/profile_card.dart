import 'package:cycle_tracker_app/dependencies.dart';

/// Widget displaying a family member's profile and cycle information
class ProfileCard extends StatelessWidget {
  final String name;
  final String? currentPhase;
  final DateTime? lastPeriodDate;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.name,
    this.currentPhase,
    this.lastPeriodDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (currentPhase != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Current Phase: $currentPhase',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (lastPeriodDate != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Last Period: ${DateFormat('MMM dd, yyyy').format(lastPeriodDate!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
