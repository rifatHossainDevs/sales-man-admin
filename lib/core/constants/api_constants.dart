class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dealership-sales-backend.onrender.com/api/v1';

  // Live GPS Tracking & Route History Endpoints
  static String liveLocations([String? companyId]) =>
      companyId != null && companyId.isNotEmpty
          ? '$baseUrl/users/gps/live-locations?companyId=$companyId'
          : '$baseUrl/users/gps/live-locations';

  static String routeHistory(String salesmanId, String date) =>
      '$baseUrl/users/gps/route-history/$salesmanId?date=$date';

  // Dashboard Analytics Endpoints
  static const String dashboardKpi = '$baseUrl/orders/dashboard/kpi-summary';
  static String dashboardSalesTrend(String period) =>
      '$baseUrl/orders/dashboard/sales-trend?period=$period';
  static const String dashboardRecentOrders = '$baseUrl/orders/dashboard/recent-orders';
  static const String dashboardLowStock = '$baseUrl/products/dashboard/low-stock-alerts';
  static String salesmenOnDuty([String? companyId]) =>
      companyId != null && companyId.isNotEmpty
          ? '$baseUrl/users/dashboard/salesmen-on-duty?companyId=$companyId'
          : '$baseUrl/users/dashboard/salesmen-on-duty';

  // Salesmen Account Endpoints
  static String allCompanyUsers(String companyId) => '$baseUrl/users/get-all-users/$companyId';
  static const String pendingSalesmen = '$baseUrl/users/salesmen/pending-approvals';
  static String approveSalesman(String id) => '$baseUrl/users/salesmen/$id/approve';
  static String rejectSalesman(String id) => '$baseUrl/users/salesmen/$id/reject';
  static String toggleSalesmanStatus(String id) => '$baseUrl/users/salesmen/$id/toggle-status';

  // Products Endpoints
  static const String products = '$baseUrl/products/get-all-products';
  static const String addProduct = '$baseUrl/products/add-product';
  static String updateProduct(String id) => '$baseUrl/products/update-product/$id';
  static String deleteProduct(String id) => '$baseUrl/products/delete-product/$id';
  static String toggleProductStatus(String id) => '$baseUrl/products/$id/toggle-status';

  // Categories & Suppliers Endpoints
  static const String categories = '$baseUrl/categories/get-all-categories';
  static const String addCategory = '$baseUrl/categories/add-category';
  static String updateCategory(String id) => '$baseUrl/categories/update-category/$id';
  static String deleteCategory(String id) => '$baseUrl/categories/delete-category/$id';

  static const String suppliers = '$baseUrl/suppliers/get-all-suppliers';
  static const String addSupplier = '$baseUrl/suppliers/add-supplier';
  static String updateSupplier(String id) => '$baseUrl/suppliers/update-supplier/$id';
  static String deleteSupplier(String id) => '$baseUrl/suppliers/delete-supplier/$id';

  // Orders Endpoints
  static const String orders = '$baseUrl/orders/admin/all-orders';
  static String markOrderFailed(String id) => '$baseUrl/orders/$id/mark-failed';

  // Stores Endpoints
  static const String stores = '$baseUrl/stores/admin/all-stores';

  // Payments Endpoints
  static const String payments = '$baseUrl/payments/admin/all-payments';
  static const String salesmanCollections = '$baseUrl/payments/admin/collection-by-salesman';

  // Company & Subscription Endpoints
  static const String allCompanies = '$baseUrl/companies/get-all-companies';
  static String companyById(String companyId) =>
      '$baseUrl/companies/get-company/$companyId';
  static String companyDetails(String companyId) =>
      '$baseUrl/companies/get-company-details-with-usage/$companyId';
  static String updateCompany(String companyId) =>
      '$baseUrl/companies/update-company/$companyId';
  static String subscriptionsByCompany(String companyId) =>
      '$baseUrl/subscriptions/get-subscriptions-by-company/$companyId';
  static const String addSubscription = '$baseUrl/subscriptions/add-subscription';

  // Territories Endpoints (Divisions, Districts, Sub-districts, Areas)
  static const String divisions = '$baseUrl/divisions/get-all-divisions';
  static const String districts = '$baseUrl/districts/get-all-districts';
  static const String addDistrict = '$baseUrl/districts/add-district';
  static String updateDistrict(String id) => '$baseUrl/districts/update-district/$id';
  static String deleteDistrict(String id) => '$baseUrl/districts/delete-district/$id';

  static const String subDistricts = '$baseUrl/sub-districts/get-all-subdistricts';
  static String subDistrictsByDis(String disNo) =>
      '$baseUrl/sub-districts/get-subDistrict-by-dis/$disNo';
  static const String addSubDistrict = '$baseUrl/sub-districts/add-subDistrict';
  static String updateSubDistrict(String id) =>
      '$baseUrl/sub-districts/update-subDistrict/$id';
  static String deleteSubDistrict(String id) =>
      '$baseUrl/sub-districts/delete-subDistrict/$id';

  static const String areas = '$baseUrl/areas/get-all-areas';
  static String areasBySubDis(String subDisNo) =>
      '$baseUrl/areas/get-area-by-subdis/$subDisNo';
  static const String addArea = '$baseUrl/areas/add-area';
  static String updateArea(String id) => '$baseUrl/areas/update-area/$id';
  static String deleteArea(String id) => '$baseUrl/areas/delete-area/$id';
}
