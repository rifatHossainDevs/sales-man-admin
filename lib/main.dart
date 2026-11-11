import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/categories_suppliers/viewmodels/categories_suppliers_viewmodel.dart';
import 'features/companies/viewmodels/company_management_viewmodel.dart';
import 'features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'features/orders/viewmodels/orders_viewmodel.dart';
import 'features/payments/viewmodels/payments_viewmodel.dart';
import 'features/products/viewmodels/products_viewmodel.dart';
import 'features/retailers/viewmodels/retailers_viewmodel.dart';
import 'features/salesmen/viewmodels/salesman_performance_viewmodel.dart';
import 'features/salesmen/viewmodels/salesmen_viewmodel.dart';
import 'features/subscriptions/viewmodels/subscription_management_viewmodel.dart';
import 'features/territories/viewmodels/territories_viewmodel.dart';
import 'features/tracking/viewmodels/live_tracking_viewmodel.dart';
import 'features/tracking/viewmodels/route_history_viewmodel.dart';
import 'routing/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<DashboardViewModel>(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider<SalesmenViewModel>(create: (_) => SalesmenViewModel()),
        ChangeNotifierProvider<PaymentsViewModel>(create: (_) => PaymentsViewModel()),
        ChangeNotifierProvider<OrdersViewModel>(create: (_) => OrdersViewModel()),
        ChangeNotifierProvider<ProductsViewModel>(create: (_) => ProductsViewModel()),
        ChangeNotifierProvider<RetailersViewModel>(create: (_) => RetailersViewModel()),
        ChangeNotifierProvider<CategoriesSuppliersViewModel>(create: (_) => CategoriesSuppliersViewModel()),
        ChangeNotifierProvider<TerritoriesViewModel>(create: (_) => TerritoriesViewModel()),
        ChangeNotifierProvider<SalesmanPerformanceViewModel>(create: (_) => SalesmanPerformanceViewModel()),
        ChangeNotifierProvider<CompanyManagementViewModel>(create: (_) => CompanyManagementViewModel()),
        ChangeNotifierProvider<SubscriptionManagementViewModel>(create: (_) => SubscriptionManagementViewModel()),
        ChangeNotifierProvider<LiveTrackingViewModel>(create: (_) => LiveTrackingViewModel()),
        ChangeNotifierProvider<RouteHistoryViewModel>(create: (_) => RouteHistoryViewModel()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return MaterialApp(
            title: 'Sales-Man Admin Panel',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: authViewModel.isAuthenticated
                ? AppRouter.dashboard
                : AppRouter.login,
            onGenerateRoute: AppRouter.onGenerateRoute,
            routes: AppRouter.routes,
          );
        },
      ),
    );
  }
}
