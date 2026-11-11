import '../models/user_model.dart';
import '../mock/mock_auth_data.dart';
import '../../features/auth/models/login_request_model.dart';
import '../../services/api_service.dart';

class AuthRepository {
  final ApiService? apiService;

  AuthRepository({this.apiService});

  Future<UserModel> login(LoginRequestModel request) async {
    // Simulate network delay for mock authentication
    await Future.delayed(const Duration(milliseconds: 1000));

    if (MockAuthData.isValidCredential(request.emailOrPhone, request.password)) {
      return MockAuthData.defaultAdminUser;
    } else {
      throw Exception('Invalid email/phone or password. Please check your credentials.');
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
