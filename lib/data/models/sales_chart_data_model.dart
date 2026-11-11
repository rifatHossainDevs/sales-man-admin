class SalesBarChartData {
  final String dayLabel;
  final double amountInLakhs;
  final bool isToday;
  final int orderCount;

  SalesBarChartData({
    required this.dayLabel,
    required this.amountInLakhs,
    this.isToday = false,
    this.orderCount = 0,
  });
}

enum SalesChartPeriod {
  sevenDays,
  thirtyDays,
  ninetyDays,
}
