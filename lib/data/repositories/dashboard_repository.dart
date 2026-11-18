import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/kpi_summary_model.dart';
import '../models/sales_chart_data_model.dart';
import '../models/salesman_duty_model.dart';
import '../models/recent_order_model.dart';
import '../models/low_stock_model.dart';
import '../mock/mock_dashboard_data.dart';
import '../mock/mock_orders_data.dart';
import '../mock/mock_payments_data.dart';
import '../../core/constants/app_colors.dart';

class DashboardRepository {
  final http.Client _client;

  DashboardRepository({http.Client? client}) : _client = client ?? http.Client();

  String _formatPercentVsYesterday(num todayVal, num yesterdayVal) {
    final t = todayVal.toDouble();
    final y = yesterdayVal.toDouble();
    if (y > 0) {
      final pct = ((t - y) / y) * 100.0;
      final sign = pct > 0 ? '+' : '';
      return '$sign${pct.toStringAsFixed(1)}% vs yesterday';
    }
    if (t > 0) {
      return '+100.0% vs yesterday';
    }
    return '0.0% vs yesterday';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<List<KpiSummaryModel>> fetchKpiSummaries() async {
    try {
      final results = await Future.wait([
        _client.get(Uri.parse(ApiConstants.dashboardKpi)),
        _client.get(Uri.parse('${ApiConstants.orders}?limit=200')),
      ]);

      final response = results[0];
      final ordersRes = results[1];

      double? computedTodaySales;
      int? computedTodayOrders;
      double yesterdaySales = 0.0;
      int yesterdayOrders = 0;
      int pendingOrdersCount = 0;
      double? computedDue;

      if (ordersRes.statusCode == 200) {
        final decoded = json.decode(ordersRes.body)['data'];
        final List ordersList = decoded is Map
            ? (decoded['orders'] ?? [])
            : (decoded is List ? decoded : []);

        final nowLocal = DateTime.now();
        final todayDate = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
        final yesterdayDate = todayDate.subtract(const Duration(days: 1));

        double tSales = 0.0;
        int tOrders = 0;
        double totalDueAcc = 0.0;

        for (final o in ordersList) {
          final rawCreated = o['createdAt']?.toString() ?? '';
          final created = DateTime.tryParse(rawCreated)?.toLocal();
          final payStatus = (o['paymentStatus'] ?? 'Pending').toString();
          final totalPrice = (o['totalPrice'] as num?)?.toDouble() ?? 0.0;
          final amountPaid = (o['amountPaid'] as num?)?.toDouble() ?? 0.0;
          final paymentDue = (o['paymentDue'] as num?)?.toDouble();

          if (payStatus == 'Pending') {
            pendingOrdersCount++;
            totalDueAcc += paymentDue ?? (totalPrice - amountPaid).clamp(0.0, double.infinity);
          }

          if (created != null) {
            if (_isSameDay(created, todayDate)) {
              tOrders++;
              if (payStatus != 'Failed') {
                tSales += totalPrice;
              }
            } else if (_isSameDay(created, yesterdayDate)) {
              yesterdayOrders++;
              if (payStatus != 'Failed') {
                yesterdaySales += totalPrice;
              }
            }
          }
        }

        computedTodaySales = tSales;
        computedTodayOrders = tOrders;
        computedDue = totalDueAcc;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final todaySales = computedTodaySales ??
            (data['todaySales'] as num?)?.toDouble() ??
            0.0;
        final todayOrders = computedTodayOrders ??
            (data['todayOrderCount'] as num?)?.toInt() ??
            0;
        final collected = (data['totalCollected'] as num?)?.toDouble() ?? 0.0;
        final due = computedDue ??
            (data['totalDue'] as num?)?.toDouble() ??
            0.0;

        final apiYesterdaySales = (data['yesterdaySales'] as num?)?.toDouble();
        final apiYesterdayOrders = (data['yesterdayOrderCount'] as num?)?.toInt();

        final effectiveYesterdaySales = apiYesterdaySales ?? yesterdaySales;
        final effectiveYesterdayOrders = apiYesterdayOrders ?? yesterdayOrders;

        final salesTrend = (data['salesTrendText']?.toString().isNotEmpty == true)
            ? data['salesTrendText'].toString()
            : _formatPercentVsYesterday(todaySales, effectiveYesterdaySales);
        final ordersTrend = (data['ordersTrendText']?.toString().isNotEmpty == true)
            ? data['ordersTrendText'].toString()
            : _formatPercentVsYesterday(todayOrders, effectiveYesterdayOrders);

        return [
          _kpi(
            "Today's Sales",
            '৳ ${_formatAmount(todaySales)}',
            salesTrend,
            Icons.trending_up_rounded,
            AppColors.primary,
            AppColors.infoBg,
          ),
          _kpi(
            'Orders Today',
            '$todayOrders',
            ordersTrend,
            Icons.shopping_bag_outlined,
            const Color(0xFF9333EA),
            const Color(0xFFF3E8FF),
          ),
          _kpi(
            'Collected today',
            '৳ ${_formatAmount(collected)}',
            'Paid collections today',
            Icons.account_balance_wallet_outlined,
            const Color(0xFF0891B2),
            const Color(0xFFCFFAFE),
          ),
          _kpi(
            'Outstanding due',
            '৳ ${_formatAmount(due)}',
            pendingOrdersCount > 0 ? '$pendingOrdersCount pending orders' : 'Pending orders',
            Icons.error_outline_rounded,
            AppColors.danger,
            AppColors.dangerBg,
          ),
        ];
      }
    } catch (_) {}

    // Fallback in-memory KPI calculations
    await Future.delayed(const Duration(milliseconds: 100));
    final orders = MockOrdersData.getInitialOrders();
    final payments = MockPaymentsData.payments;

    final todayOrders = orders.where((o) => o.date.contains('10 Nov') || o.date.contains('10 Nov 2026')).toList();
    final todaySales = (todayOrders.isNotEmpty ? todayOrders : orders)
        .where((order) => order.paymentStatus != 'Failed')
        .fold<double>(0, (sum, order) => sum + order.totalAmount);

    final todayOrderCount = todayOrders.isNotEmpty ? todayOrders.length : 38;

    final collected = payments
        .where((p) => p.status == 'Paid')
        .fold<double>(0, (sum, p) => sum + p.amount);
    final pending = orders.where((o) => o.paymentStatus == 'Pending').toList();
    final due = pending.fold<double>(0, (sum, o) => sum + o.dueAmount);

    return [
      _kpi(
        "Today's Sales",
        '৳ ${todaySales > 0 ? _formatAmount(todaySales) : "4,82,500"}',
        '+12.4% vs yesterday',
        Icons.trending_up_rounded,
        AppColors.primary,
        AppColors.infoBg,
      ),
      _kpi(
        'Orders Today',
        '$todayOrderCount',
        '+5 vs yesterday',
        Icons.shopping_bag_outlined,
        const Color(0xFF9333EA),
        const Color(0xFFF3E8FF),
      ),
      _kpi(
        'Collected today',
        '৳ ${_formatAmount(collected)}',
        '${payments.where((p) => p.status == 'Paid').length} paid records',
        Icons.account_balance_wallet_outlined,
        const Color(0xFF0891B2),
        const Color(0xFFCFFAFE),
      ),
      _kpi(
        'Outstanding due',
        '৳ ${_formatAmount(due)}',
        '${pending.length} pending orders',
        Icons.error_outline_rounded,
        AppColors.danger,
        AppColors.dangerBg,
      ),
    ];
  }

  String _formatAmount(double amount) {
    final int val = amount.toInt();
    final String str = val.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final otherNumbers = str.substring(0, str.length - 3);
    final result = otherNumbers.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$result,$lastThree';
  }

  Future<List<SalesBarChartData>> fetchSalesChartData(
    SalesChartPeriod period,
  ) async {
    final periodStr = period == SalesChartPeriod.ninetyDays ? '90D' : (period == SalesChartPeriod.thirtyDays ? '30D' : '7D');
    try {
      final response = await _client.get(Uri.parse(ApiConstants.dashboardSalesTrend(periodStr)));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((item) {
          return SalesBarChartData(
            dayLabel: item['dayLabel'] ?? '',
            amountInLakhs: (item['amountInLakhs'] as num).toDouble(),
            isToday: item['isToday'] ?? false,
            orderCount: item['orderCount'] ?? 0,
          );
        }).toList();
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 100));
    return MockDashboardData.getSalesChartData(period);
  }

  Future<Map<String, int>> _fetchSalesmanOrderCounts() async {
    final counts = <String, int>{};
    try {
      final res = await _client.get(Uri.parse('${ApiConstants.orders}?limit=200'));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final List ordersList = decoded['data'] is Map
            ? (decoded['data']['orders'] ?? [])
            : (decoded['data'] is List ? decoded['data'] : []);
        for (final item in ordersList) {
          final salesman = item['salesmanId'];
          final sId = (salesman is Map ? salesman['_id'] : salesman)?.toString() ?? '';
          final sName = (salesman is Map ? salesman['fullName'] : '')?.toString().trim().toLowerCase() ?? '';
          if (sId.isNotEmpty) {
            counts[sId] = (counts[sId] ?? 0) + 1;
          }
          if (sName.isNotEmpty) {
            counts[sName] = (counts[sName] ?? 0) + 1;
          }
        }
      }
    } catch (_) {}
    return counts;
  }

  Future<List<SalesmanDutyModel>> fetchSalesmenOnDuty({String? companyId}) async {
    final orderCounts = await _fetchSalesmanOrderCounts();
    try {
      final response = await _client.get(Uri.parse(ApiConstants.salesmenOnDuty(companyId)));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          return data.map((item) {
            final id = (item['salesmanId'] ?? item['_id'] ?? '').toString();
            final name = (item['name'] ?? item['fullName'] ?? '').toString();
            final apiCount = (item['ordersCount'] as num?)?.toInt() ?? 0;
            final resolvedCount = apiCount > 0
                ? apiCount
                : (orderCounts[id] ?? orderCounts[name.trim().toLowerCase()] ?? 0);
            return SalesmanDutyModel(
              id: id,
              name: name,
              initials: (item['initials'] ?? 'SR').toString(),
              location: (item['location'] ?? 'In Market').toString(),
              ordersCount: resolvedCount,
              isOnline: item['isOnline'] == true,
            );
          }).toList();
        }
      }
    } catch (_) {}

    // Fallback: Query company sellers directly from MongoDB /get-all-users/:companyId
    if (companyId != null && companyId.isNotEmpty) {
      try {
        final response = await _client.get(Uri.parse(ApiConstants.allCompanyUsers(companyId)));
        if (response.statusCode == 200) {
          final List data = json.decode(response.body)['data'] ?? [];
          final sellers = data.where((item) => item['userType'] == 'seller').toList();
          return sellers.map((s) {
            final id = (s['_id'] ?? '').toString();
            final fullName = (s['fullName'] ?? 'Salesman').toString().trim();
            final nameParts = fullName.split(RegExp(r'\s+'));
            final initials = nameParts.length > 1
                ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
                : (fullName.isNotEmpty ? fullName.substring(0, fullName.length.clamp(1, 2)).toUpperCase() : 'SR');
            final isOnline = s['isOnline'] == true;
            final resolvedCount = orderCounts[id] ?? orderCounts[fullName.toLowerCase()] ?? 0;

            return SalesmanDutyModel(
              id: id,
              name: fullName,
              initials: initials,
              location: isOnline ? 'In Market · Online' : 'Offline',
              ordersCount: resolvedCount,
              isOnline: isOnline,
            );
          }).toList();
        }
      } catch (_) {}
    }

    return const [];
  }

  Future<List<RecentOrderModel>> fetchRecentOrders() async {
    try {
      final storesById = <String, String>{};
      try {
        final storesRes = await _client.get(Uri.parse('${ApiConstants.stores}?limit=200'));
        if (storesRes.statusCode == 200) {
          final storesDecoded = json.decode(storesRes.body)['data'];
          final List storesList = storesDecoded is Map
              ? (storesDecoded['stores'] ?? [])
              : (storesDecoded is List ? storesDecoded : []);
          for (final st in storesList) {
            final stId = (st['_id'] ?? '').toString();
            final uId = (st['userId'] is Map ? st['userId']['_id'] : st['userId'])?.toString() ?? '';
            final name = (st['storeName'] ?? st['storeOwnerName'] ?? '').toString();
            if (name.isNotEmpty) {
              if (stId.isNotEmpty) storesById[stId] = name;
              if (uId.isNotEmpty) storesById[uId] = name;
            }
          }
        }
      } catch (_) {}

      final response = await _client.get(Uri.parse(ApiConstants.dashboardRecentOrders));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((item) {
          final storeInfo = item['storeInfo'] is Map ? item['storeInfo'] : {};
          final customer = item['customerId'] is Map ? item['customerId'] : {};
          final salesman = item['salesmanId'] is Map ? item['salesmanId'] : {};
          final custIdStr = (customer['_id'] ?? item['customerId'] ?? '').toString();

          final retailerName = (storeInfo['storeName'] ??
                  customer['storeName'] ??
                  storesById[custIdStr] ??
                  storeInfo['storeOwnerName'] ??
                  customer['fullName'] ??
                  'Retail Store')
              .toString();
          final salesmanName = (salesman['fullName'] ?? 'Sales Rep').toString();

          return RecentOrderModel(
            invoiceNo: (item['invoiceNumber'] ?? 'INV-000').toString(),
            retailerName: retailerName,
            salesmanName: salesmanName,
            totalAmount: (item['totalPrice'] as num?)?.toDouble() ?? 0.0,
            paymentStatus: (item['paymentStatus'] ?? 'Pending').toString(),
            shipmentStatus: (item['shipmentStatus'] ?? 'Pending').toString(),
          );
        }).toList();
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 100));
    final orders = MockOrdersData.getInitialOrders();
    return orders
        .take(5)
        .map(
          (o) => RecentOrderModel(
            invoiceNo: o.invoiceNo,
            retailerName: o.retailerName,
            salesmanName: o.salesmanName,
            totalAmount: o.totalAmount,
            paymentStatus: o.paymentStatus,
            shipmentStatus: o.shipmentStatus,
          ),
        )
        .toList();
  }

  Future<List<LowStockModel>> fetchLowStockAlerts() async {
    try {
      final response = await _client.get(Uri.parse(ApiConstants.dashboardLowStock));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((item) {
          return LowStockModel(
            id: item['_id'] ?? '',
            productName: item['productName'] ?? '',
            sku: item['sku'] ?? '',
            currentStock: item['stockQuantity'] ?? 0,
          );
        }).toList();
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 100));
    return MockDashboardData.getLowStockAlerts();
  }
}

KpiSummaryModel _kpi(
  String title,
  String value,
  String trend,
  IconData icon,
  Color iconColor,
  Color background,
) => KpiSummaryModel(
  title: title,
  value: value,
  trendText: trend,
  icon: icon,
  iconColor: iconColor,
  iconBgColor: background,
  trendColor: iconColor,
);
