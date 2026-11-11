class LoginRequestModel {
  final String emailOrPhone;
  final String password;
  final bool keepSignedIn;

  LoginRequestModel({
    required this.emailOrPhone,
    required this.password,
    this.keepSignedIn = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'emailOrPhone': emailOrPhone,
      'password': password,
      'keepSignedIn': keepSignedIn,
    };
  }
}
