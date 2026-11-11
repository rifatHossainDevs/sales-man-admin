import '../models/user_model.dart';

class MockAuthData {
  static final UserModel defaultAdminUser = UserModel(
    id: 'usr_admin_001',
    name: 'Anwar Hossain',
    email: 'admin@dhakadealership.com',
    role: 'Admin',
    dealershipName: 'Dhaka Dealership',
    avatarInitials: 'AH',
  );

  static const String mockPassword = 'password123';

  static bool isValidCredential(String emailOrPhone, String password) {
    final cleanInput = emailOrPhone.trim().toLowerCase();
    final isEmailOrPhoneMatch = cleanInput == 'admin@dhakadealership.com' ||
        cleanInput == 'admin' ||
        cleanInput == '01711000111';
    
    return isEmailOrPhoneMatch && (password == 'password123' || password == '12345678' || password.length >= 6);
  }
}
