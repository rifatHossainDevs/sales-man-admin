import '../models/category_supplier_model.dart';

class MockCategoriesSuppliersData {
  static List<CategoryModel> getCategories() {
    return [
      const CategoryModel(
        id: 'cat_1',
        name: 'Rice & Grains',
        description: 'Rice, lentil, sugar',
        productCount: 34,
      ),
      const CategoryModel(
        id: 'cat_2',
        name: 'Cooking Oil',
        description: 'Edible oils',
        productCount: 12,
      ),
      const CategoryModel(
        id: 'cat_3',
        name: 'Dairy',
        description: 'Milk and milk products',
        productCount: 16,
      ),
      const CategoryModel(
        id: 'cat_4',
        name: 'Beverages',
        description: 'Juice, soft drinks',
        productCount: 18,
      ),
      const CategoryModel(
        id: 'cat_5',
        name: 'Personal Care',
        description: 'Soap, shampoo',
        productCount: 14,
      ),
      const CategoryModel(
        id: 'cat_6',
        name: 'Household',
        description: 'Cleaning products',
        productCount: 15,
      ),
      const CategoryModel(
        id: 'cat_7',
        name: 'Snacks',
        description: 'Biscuits, chips',
        productCount: 11,
      ),
      const CategoryModel(
        id: 'cat_8',
        name: 'Spices',
        description: 'Powder and whole spices',
        productCount: 6,
      ),
    ];
  }

  static List<SupplierModel> getSuppliers() {
    return [
      const SupplierModel(
        id: 'sup_1',
        name: 'Golden Mills Ltd.',
        location: 'Dhaka, Bangladesh',
        phone: '01711-100200',
        email: 'info@goldenmills.com',
        productCount: 28,
      ),
      const SupplierModel(
        id: 'sup_2',
        name: 'Agro Fresh',
        location: 'Dhaka, Bangladesh',
        phone: '01811-300400',
        email: 'sales@agrofresh.com',
        productCount: 12,
      ),
      const SupplierModel(
        id: 'sup_3',
        name: 'Pure Harvest',
        location: 'Dhaka, Bangladesh',
        phone: '01911-500600',
        email: 'hello@pureharvest.com',
        productCount: 22,
      ),
      const SupplierModel(
        id: 'sup_4',
        name: 'Dhaka Dairy Co.',
        location: 'Dhaka, Bangladesh',
        phone: '01611-700800',
        email: 'orders@dhakadairy.com',
        productCount: 16,
      ),
      const SupplierModel(
        id: 'sup_5',
        name: 'CleanHome BD',
        location: 'Dhaka, Bangladesh',
        phone: '01511-900100',
        email: 'care@cleanhome.com',
        productCount: 15,
      ),
      const SupplierModel(
        id: 'sup_6',
        name: 'Spice Route',
        location: 'Dhaka, Bangladesh',
        phone: '01755-200300',
        email: 'buy@spiceroute.com',
        productCount: 6,
      ),
    ];
  }
}
