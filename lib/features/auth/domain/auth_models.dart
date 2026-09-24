/// Represents a user session after successful authentication.
class UserSession {
  final String userId;
  final String customerId;
  final String name;
  final String token;

  const UserSession({
    required this.userId,
    required this.customerId,
    required this.name,
    required this.token,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] as String,
      customerId: json['customerId'] as String,
      name: json['name'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'customerId': customerId,
    'name': name,
    'token': token,
  };
}

/// Login request payload.
class LoginRequest {
  final String customerId;
  final String pin;

  const LoginRequest({required this.customerId, required this.pin});

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    // SECURITY: PIN is sent as a hash in production.
    // Never log or store the raw PIN.
    'pin': pin,
  };
}
