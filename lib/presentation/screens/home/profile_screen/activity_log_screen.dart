import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityLogScreen extends StatelessWidget {
  final List<Map<String, dynamic>> activityLogs;

  const ActivityLogScreen({super.key, required this.activityLogs});

  @override
  Widget build(BuildContext context) {
    // Group activities by type
    final Map<String, int> activityCount = {};
    for (var activity in activityLogs) {
      final type = activity['activity_type'] ?? 'Unknown';
      activityCount[type] = (activityCount[type] ?? 0) + 1;
    }

    // Sort recent activities
    final recentActivities = List<Map<String, dynamic>>.from(activityLogs)
      ..sort(
        (a, b) => DateTime.parse(
          b['time_performed'],
        ).compareTo(DateTime.parse(a['time_performed'])),
      );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: activityCount.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.all(16),
                width: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // ==============================
          // Recent Activities
          // ==============================
          const Text(
            "Recent Activities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: activityLogs.isEmpty
                ? const Center(child: Text("No recent activity."))
                : ListView.builder(
                    itemCount: recentActivities.length,
                    itemBuilder: (context, index) {
                      final activity = recentActivities[index];
                      final date = DateTime.parse(
                        activity['time_performed'],
                      ).toLocal();
                      final formattedDate = DateFormat(
                        'yyyy-MM-dd – HH:mm',
                      ).format(date);

                      IconData icon;
                      switch (activity['activity_type']) {
                        case 'task':
                          icon = Icons.check_circle_outline;
                          break;
                        case 'login':
                          icon = Icons.login;
                          break;
                        case 'module':
                          icon = Icons.extension;
                          break;
                        default:
                          icon = Icons.history;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 0,
                        ),
                        child: ListTile(
                          leading: Icon(
                            icon,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          title: Text(activity['activity_type']),
                          subtitle: Text(
                            activity['activity_description'] ?? "",
                          ),
                          trailing: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
