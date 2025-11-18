import 'package:flutter/material.dart';
import 'package:flutter_basic_starter_kit/core/utils/features.dart';
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/database_helper.dart';
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/user_crud.dart';
import 'package:flutter_basic_starter_kit/presentation/components/custom_tooltip.dart';

import 'package:sqflite/sqflite.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? currentPlan = 'Free';
  String? expireDate;

  final List<String> durations = [
    '1 month',
    '3 months',
    '6 months',
    '1 year',
    '2 years',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSubscription();
  }

  Future<void> _loadUserSubscription() async {
    final dbHelper = DatabaseHelper();
    final userData = await dbHelper.getCurrentUserWithSubscription();
    if (userData != null) {
      setState(() {
        currentPlan = userData['subscription'];
        expireDate = userData['expireDate'];
      });
    }
  }

  Future<void> subscribeToPlan(BuildContext context, String planName) async {
    String? selectedDuration;
    String amount = "";

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text("Subscribe to $planName"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Duration',
                      border: OutlineInputBorder(),
                    ),
                    items: durations
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDuration = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) => amount = value,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDuration == null || amount.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select duration and amount'),
                        ),
                      );
                      return;
                    }

                    final dbHelper = DatabaseHelper();
                    final db = await dbHelper.database;
                    final userId = await dbHelper.getLoggedInUserId();
                    final now = DateTime.now();

                    DateTime renewDate = now;
                    switch (selectedDuration) {
                      case '1 month':
                        renewDate = now.add(const Duration(days: 30));
                        break;
                      case '3 months':
                        renewDate = now.add(const Duration(days: 90));
                        break;
                      case '6 months':
                        renewDate = now.add(const Duration(days: 180));
                        break;
                      case '1 year':
                        renewDate = DateTime(now.year + 1, now.month, now.day);
                        break;
                      case '2 years':
                        renewDate = DateTime(now.year + 2, now.month, now.day);
                        break;
                    }

                    await db.insert(
                      'subscriptions',
                      {
                        'user_id': userId,
                        'subscription_name': planName,
                        'purchase_date': now.toIso8601String(),
                        'renew_date': renewDate.toIso8601String(),
                      },
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );

                    Navigator.of(ctx).pop();

                    await _loadUserSubscription();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ Subscribed to $planName for $selectedDuration at \$$amount',
                        ),
                      ),
                    );
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Map<String, List<Feature>> categorizedFeatures = {};
    for (var feature in allFeatures) {
      categorizedFeatures.putIfAbsent(feature.category, () => []).add(feature);
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentPlan != null) ...[
              Text(
                'Current Plan: $currentPlan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (expireDate != null) Text('Expires on: $expireDate'),
              const SizedBox(height: 24),
            ],
            Text(
              "Choose Your Plan",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: plans.map((plan) {
                  final planFeatures = plan.featureIndexes
                      .map((index) => allFeatures[index].name)
                      .toSet();

                  return Expanded(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${plan.price} / month",
                              style: TextStyle(color: colorScheme.primary),
                            ),
                            const SizedBox(height: 16),
                            ...categorizedFeatures.entries.map((entry) {
                              final category = entry.key;

                              // Filter only features in this category that are part of the current plan
                              final includedFeatures = entry.value
                                  .where(
                                    (feature) =>
                                        planFeatures.contains(feature.name),
                                  )
                                  .toList();

                              if (includedFeatures.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...includedFeatures.map((feature) {
                                    return CustomTooltip(
                                      message: feature.description,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(child: Text(feature.name)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                ],
                              );
                            }),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                onPressed: currentPlan == plan.name
                                    ? null
                                    : () => subscribeToPlan(context, plan.name),
                                child: Text(
                                  currentPlan == plan.name
                                      ? 'Subscribed'
                                      : 'Subscribe',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
