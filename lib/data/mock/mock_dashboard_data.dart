import '../models/sales_chart_data_model.dart';
import '../models/salesman_duty_model.dart';
import '../models/low_stock_model.dart';
import 'mock_orders_data.dart';

class MockDashboardData {
  static int _ordersFor(String name) => MockOrdersData.getInitialOrders()
      .where((order) => order.salesmanName == name)
      .length;

  static List<SalesBarChartData> getSalesChartData(SalesChartPeriod period) {
    final orders = MockOrdersData.getInitialOrders();
    final dates = orders
        .map((order) => _parseOrderDate(order.date))
        .whereType<DateTime>()
        .toList();
    if (dates.isEmpty) return [];
    final latest = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    final days = switch (period) {
      SalesChartPeriod.sevenDays => 7,
      SalesChartPeriod.thirtyDays => 30,
      SalesChartPeriod.ninetyDays => 90,
    };
    return List.generate(days, (index) {
      final date = DateTime(
        latest.year,
        latest.month,
        latest.day,
      ).subtract(Duration(days: days - index - 1));
      final dayOrders = orders.where((order) {
        final orderDate = _parseOrderDate(order.date);
        return orderDate != null &&
            orderDate.year == date.year &&
            orderDate.month == date.month &&
            orderDate.day == date.day;
      }).toList();
      final amount = dayOrders
          .where((order) => order.paymentStatus != 'Failed')
          .fold<double>(0, (sum, order) => sum + order.totalAmount);
      final label = days == 7
          ? const [
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat',
              'Sun',
            ][date.weekday - 1]
          : '${date.day}/${date.month}';
      return SalesBarChartData(
        dayLabel: label,
        amountInLakhs: amount / 100000,
        isToday: index == days - 1,
        orderCount: dayOrders.length,
      );
    });
  }

  static DateTime? _parseOrderDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      try {
        final parts = value.split(' ');
        const months = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };
        return DateTime(
          int.parse(parts[2]),
          months[parts[1]]!,
          int.parse(parts[0]),
        );
      } catch (_) {
        return null;
      }
    }
  }

  static List<SalesmanDutyModel> getSalesmenOnDuty() {
    return [
      SalesmanDutyModel(
        id: 'sm_01',
        name: 'Rakib Hasan',
        initials: 'RH',
        location: 'Mirpur-10 · 12 s ago',
        ordersCount: _ordersFor('Rakib Hasan'),
        isOnline: true,
      ),
      SalesmanDutyModel(
        id: 'sm_02',
        name: 'Sohel Rana',
        initials: 'SR',
        location: 'Pallabi · 1 min ago',
        ordersCount: _ordersFor('Sohel Rana'),
        isOnline: true,
      ),
      SalesmanDutyModel(
        id: 'sm_03',
        name: 'Nusrat Jahan',
        initials: 'NJ',
        location: 'Kafrul · 3 min ago',
        ordersCount: _ordersFor('Nusrat Jahan'),
        isOnline: true,
      ),
      SalesmanDutyModel(
        id: 'sm_04',
        name: 'Imran Hossain',
        initials: 'IH',
        location: 'Mirpur-11 · idle 12 min',
        ordersCount: _ordersFor('Imran Hossain'),
        isOnline: false,
      ),
    ];
  }

  static List<LowStockModel> getLowStockAlerts() {
    return [
      LowStockModel(
        id: 'stk_01',
        productName: 'Sunflower Oil 1L',
        sku: 'OIL-1L-014',
        currentStock: 6,
      ),
      LowStockModel(
        id: 'stk_02',
        productName: 'Basmati Rice 5kg',
        sku: 'RIC-5K-002',
        currentStock: 9,
      ),
      LowStockModel(
        id: 'stk_03',
        productName: 'Powder Milk 500g',
        sku: 'MLK-500-007',
        currentStock: 11,
      ),
      LowStockModel(
        id: 'stk_04',
        productName: 'Detergent Powder 1kg',
        sku: 'DET-1K-021',
        currentStock: 14,
      ),
      LowStockModel(
        id: 'stk_05',
        productName: 'Lentil (Masoor) 1kg',
        sku: 'LEN-1K-009',
        currentStock: 18,
      ),
    ];
  }
}
