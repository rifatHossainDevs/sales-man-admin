import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/web_platform.dart';
import '../models/user_model.dart';
import '../../features/auth/models/login_request_model.dart';

class AuthRepository {
  final http.Client _client;
  static const String _userSessionKey = 'saved_user_session_key';
  static const String _tokenKey = 'jwt_token_key';

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  static Map<String, String> getAuthHeaders([String? token]) {
    String? jwt = token;
    if (jwt == null || jwt.isEmpty) {
      jwt = WebPlatform.getLocalStorageItem(_tokenKey);
    }

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
    }
    return headers;
  }

  // Synchronous web session loader for instant page refresh recovery
  UserModel? loadSavedUserSync() {
    try {
      final userJson = WebPlatform.getLocalStorageItem(_userSessionKey);
      if (userJson != null && userJson.isNotEmpty) {
        final user = UserModel.fromJson(json.decode(userJson));
        // Ensure saved user is Admin
        if (user.role.toLowerCase() == 'seller') {
          WebPlatform.removeLocalStorageItem(_userSessionKey);
          WebPlatform.removeLocalStorageItem(_tokenKey);
          return null;
        }
        return user;
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel> login(LoginRequestModel request) async {
    final input = request.emailOrPhone.trim();
    final Map<String, String> body = {
      'password': request.password.trim(),
    };

    if (input.contains('@')) {
      body['email'] = input;
    } else {
      body['phone'] = input;
    }

    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      Map<String, dynamic>? data;
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}

      if (response.statusCode == 200 && data != null && data['success'] == true) {
        final userData = data['data']['user'];
        final userType = (userData['userType'] ?? '').toString().toLowerCase();
        final accessToken = (data['data']['accessToken'] ?? '').toString();

        // Strict Authorization: Block seller accounts from Admin Console
        if (userType == 'seller') {
          throw Exception('Access Denied: Salesmen (sellers) are not authorized to log into the Admin Console.');
        }

        final fullName = (userData['fullName'] ?? 'Admin User').toString().trim();
        final initialsParts = fullName.split(RegExp(r'\s+'));
        final initials = initialsParts.length > 1
            ? '${initialsParts[0][0]}${initialsParts[1][0]}'.toUpperCase()
            : (fullName.isNotEmpty ? fullName.substring(0, fullName.length.clamp(1, 2)).toUpperCase() : 'AD');

        final companyId = (userData['companyId'] ?? '').toString();
        String dealershipName = (userData['companyName'] ?? '').toString().trim();
        if (dealershipName.isEmpty && companyId.isNotEmpty) {
          try {
            final compRes = await _client.get(
              Uri.parse(ApiConstants.companyById(companyId)),
              headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
            );
            if (compRes.statusCode == 200) {
              final compData = json.decode(compRes.body)['data'];
              if (compData is Map && compData['companyName'] != null) {
                dealershipName = compData['companyName'].toString().trim();
              }
            }
          } catch (_) {}
        }
        if (dealershipName.isEmpty) {
          dealershipName = 'Dhaka Dealership Ltd.';
        }

        final user = UserModel(
          id: (userData['_id'] ?? '').toString(),
          name: fullName,
          email: (userData['email'] ?? input).toString(),
          role: userType.toUpperCase(),
          dealershipName: dealershipName,
          avatarInitials: initials,
          companyId: companyId,
          token: accessToken,
        );

        // Save session synchronously in browser localStorage
        WebPlatform.setLocalStorageItem(_userSessionKey, json.encode(user.toJson()));
        WebPlatform.setLocalStorageItem(_tokenKey, accessToken);

        return user;
      } else {
        final errorMsg = data?['message']?.toString() ??
            (response.statusCode == 404
                ? 'Account not found. Please check your email or phone number.'
                : 'Invalid email/phone or password.');
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Could not connect to backend server at ${ApiConstants.baseUrl}. Please check your connection.');
    }
  }

  Future<void> logout() async {
    try {
      final headers = getAuthHeaders();
      WebPlatform.removeLocalStorageItem(_userSessionKey);
      WebPlatform.removeLocalStorageItem(_tokenKey);
      await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/users/logout'),
        headers: headers,
      );
    } catch (_) {}
  }
}
