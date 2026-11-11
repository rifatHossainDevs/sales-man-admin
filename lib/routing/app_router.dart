import 'package:flutter/material.dart';
import '../features/auth/views/login_view.dart';
import '../features/categories_suppliers/views/categories_suppliers_view.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/orders/views/orders_view.dart';
import '../features/payments/views/payments_view.dart';
import '../features/products/views/products_view.dart';
import '../features/retailers/views/retailers_view.dart';
import '../features/salesmen/views/salesmen_view.dart';
import '../features/salesmen/views/salesman_performance_view.dart';
import '../features/companies/views/company_subscription_view.dart';
import '../features/territories/views/territories_view.dart';
import '../features/tracking/views/live_tracking_view.dart';
import '../features/tracking/views/route_history_view.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String liveTracking = '/live-tracking';
  static const String routeHistory = '/route-history';
  static const String salesmen = '/salesmen';
  static const String orders = '/orders';
  static const String payments = '/payments';
  static const String retailers = '/retailers';
  static const String products = '/products';
  static const String categoriesSuppliers = '/categories-suppliers';
  static const String territories = '/territories';
  static const String salesmanPerformance = '/salesman-performance';
  static const String companySubscription = '/company-subscription';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginView(),
      dashboard: (context) => const DashboardView(),
      liveTracking: (context) => const LiveTrackingView(),
      routeHistory: (context) => const RouteHistoryView(),
      salesmen: (context) => const SalesmenView(),
      orders: (context) => const OrdersView(),
      payments: (context) => const PaymentsView(),
      retailers: (context) => const RetailersView(),
      products: (context) => const ProductsView(),
      categoriesSuppliers: (context) => const CategoriesSuppliersView(),
      territories: (context) => const TerritoriesView(),
      salesmanPerformance: (context) => const SalesmanPerformanceView(),
      companySubscription: (context) => const CompanySubscriptionView(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    return MaterialPageRoute(
      builder: (_) => const LoginView(),
      settings: settings,
    );
  }
}
