// ───────────────────────────────────────────────────────────────
// exceptions.dart  –  Typed exceptions for error handling
// ───────────────────────────────────────────────────────────────

abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}
