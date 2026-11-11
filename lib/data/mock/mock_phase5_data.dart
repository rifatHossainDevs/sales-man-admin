class SubscriptionPlan {
  final String id;
  final String name;
  final int? maxAdmins;
  final int? maxSalesRepresentatives;
  final int? maxCustomers;
  final String priceLabel;
  final double? annualPrice;
  final int durationMonths;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.maxAdmins,
    required this.maxSalesRepresentatives,
    required this.maxCustomers,
    required this.priceLabel,
    required this.annualPrice,
    this.durationMonths = 12,
    required this.features,
  });

  String limit(int? value) => value == null ? 'Unlimited' : value.toString();
}

class CompanyRecord {
  final String id, name, email, phone, address, planId, status;
  final DateTime subscriptionStart, subscriptionEnd;
  final int admins, salesRepresentatives, customers;

  const CompanyRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.planId,
    required this.status,
    required this.subscriptionStart,
    required this.subscriptionEnd,
    required this.admins,
    required this.salesRepresentatives,
    required this.customers,
  });
  bool get subscriptionExpired => subscriptionEnd.isBefore(DateTime.now());
}

class SubscriptionHistoryRecord {
  final String companyId, planId, status;
  final DateTime start, end;
  final double? price;

  const SubscriptionHistoryRecord({
    required this.companyId,
    required this.planId,
    required this.status,
    required this.start,
    required this.end,
    required this.price,
  });
}

class MockPhase5Data {
  static const monthlySalesTargets = <String, double>{
    'Rakib Hasan': 420000,
    'Sohel Rana': 400000,
    'Nusrat Jahan': 320000,
    'Farhana Akter': 300000,
    'Tanvir Ahmed': 260000,
    'Imran Hossain': 220000,
    'Mahmudul Karim': 180000,
    'Shirin Akter': 180000,
  };
  static const plans = <SubscriptionPlan>[
    SubscriptionPlan(
      id: 'starter',
      name: 'Starter',
      maxAdmins: 2,
      maxSalesRepresentatives: 10,
      maxCustomers: 500,
      priceLabel: '৳ 12,000 / year',
      annualPrice: 12000,
      features: [
        'Orders and payments',
        'Email support',
        'Up to 10 sales representatives',
      ],
    ),
    SubscriptionPlan(
      id: 'professional',
      name: 'Professional',
      maxAdmins: 5,
      maxSalesRepresentatives: 20,
      maxCustomers: 1000,
      priceLabel: 'Pricing to be configured',
      annualPrice: null,
      features: [
        'Advanced reports',
        'Priority support',
        'Up to 20 sales representatives',
      ],
    ),
    SubscriptionPlan(
      id: 'enterprise',
      name: 'Enterprise',
      maxAdmins: null,
      maxSalesRepresentatives: null,
      maxCustomers: null,
      priceLabel: 'Custom pricing',
      annualPrice: null,
      features: [
        'Unlimited accounts and customers',
        'Multiple branches',
        'Dedicated account support',
      ],
    ),
  ];

  static final companies = <CompanyRecord>[
    CompanyRecord(
      id: 'CMP-1001',
      name: 'Dhaka Dealership Ltd.',
      email: 'info@dhakadealership.com',
      phone: '01711-000111',
      address: 'House 12, Road 4, Mirpur-10, Dhaka-1216',
      planId: 'enterprise',
      status: 'Active',
      subscriptionStart: DateTime(2026, 1, 1),
      subscriptionEnd: DateTime(2026, 12, 31),
      admins: 2,
      salesRepresentatives: 18,
      customers: 214,
    ),
  ];

  static final history = <SubscriptionHistoryRecord>[
    SubscriptionHistoryRecord(
      companyId: 'CMP-1001',
      planId: 'enterprise',
      status: 'Active',
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 12, 31),
      price: null,
    ),
    SubscriptionHistoryRecord(
      companyId: 'CMP-1001',
      planId: 'starter',
      status: 'Expired',
      start: DateTime(2025, 1, 1),
      end: DateTime(2025, 12, 31),
      price: 12000,
    ),
  ];
}
