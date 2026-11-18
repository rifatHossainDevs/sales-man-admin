class SalesmanCollectionModel {
  final String id;
  final String salesmanName;
  final String avatarInitials;
  final double amountCollected;
  final double progressPercentage;

  const SalesmanCollectionModel({
    required this.id,
    required this.salesmanName,
    required this.avatarInitials,
    required this.amountCollected,
    required this.progressPercentage,
  });

  String get name => salesmanName;
  double get amount => amountCollected;
  double get percentageOfMax => progressPercentage;
}
