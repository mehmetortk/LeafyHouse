// lib/core/error/exceptions.dart

class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException({required this.message});
}

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException({required this.message});
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException({required this.message});
}

class InvalidInputException implements Exception {
  final String message;
  InvalidInputException({required this.message});
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException({required this.message});
}

class UnexpectedException implements Exception {
  final String message;
  UnexpectedException({required this.message});
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException({required this.message});
}

class FileNotFoundException implements Exception {
  final String message;
  FileNotFoundException({required this.message});
}

class InsufficientStorageException implements Exception {
  final String message;
  InsufficientStorageException({required this.message});
}

class DuplicateEntryException implements Exception {
  final String message;
  DuplicateEntryException({required this.message});
}

class InvalidCredentialException implements Exception {
  final String message;
  InvalidCredentialException({required this.message});
}

class OperationCancelledException implements Exception {
  final String message;
  OperationCancelledException({required this.message});
}
