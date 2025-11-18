class Feature {
  final String name;
  final String description;
  final String category;

  Feature({
    required this.name,
    required this.description,
    required this.category,
  });
}

class Plan {
  final String name;
  final String price;
  final List<int> featureIndexes;

  Plan({required this.name, required this.price, required this.featureIndexes});
}

// Master list of all features grouped by category
final List<Feature> allFeatures = [
  Feature(
    name: 'Basic access',
    description:
        'Access to core features with up to 20 use-case activities per day',
    category: 'Core',
  ),
  Feature(
    name: 'Advanced access',
    description:
        'Access to core and advanced features with up to 100 use-case activities per day',
    category: 'Core',
  ),
  Feature(
    name: 'Unlimited access',
    description:
        'Access all features with unlimited functionality and use-case activities',
    category: 'Core',
  ),
  Feature(
    name: 'Limited projects (10)',
    description: 'Create and manage up to 10 projects.',
    category: 'Projects',
  ),
  Feature(
    name: 'Limited projects (50)',
    description: 'Create and manage up to 50 projects.',
    category: 'Projects',
  ),
  Feature(
    name: 'Unlimited projects',
    description: 'Create and manage unlimited projects.',
    category: 'Projects',
  ),
  Feature(
    name: 'Community support',
    description: 'Get help and advice from the user community.',
    category: 'Support',
  ),
  Feature(
    name: 'One-time support',
    description: 'Get help for a single issue or question.',
    category: 'Support',
  ),

  Feature(
    name: 'Priority support',
    description: 'Get faster response times from our support team.',
    category: 'Support',
  ),
  Feature(
    name: 'Dedicated support',
    description: 'Get advanced support from our dedicated team.',
    category: 'Support',
  ),
  Feature(
    name: 'Market tools',
    description: 'Access tools to help check market data, promote and sell.',
    category: 'Tools',
  ),
  Feature(
    name: 'PDF tools',
    description:
        'Access tools that helps measurements and calculations from pdf blueprints.',
    category: 'Tools',
  ),

  /** Feature(
    name: 'Team collaboration',
    description: 'Invite team members and work together in real-time.',
    category: 'Collaboration',
  ), */
  Feature(
    name: 'Advanced analytics',
    description: 'Detailed metrics and insights about your usage.',
    category: 'Analytics',
  ),
  Feature(
    name: 'Audit logs',
    description: 'Full access to activity logs and change tracking.',
    category: 'Compliance',
  ),
];

// Subscription plans with feature index references
final List<Plan> plans = [
  Plan(name: 'Free', price: '0', featureIndexes: [0, 3, 7, 6]),

  Plan(name: 'Pro', price: '9.99', featureIndexes: [1, 4, 6, 8, 10]),
  Plan(
    name: 'Enterprise',
    price: '29.99',
    featureIndexes: [2, 5, 6, 9, 10, 11, 12, 13],
  ),
];
