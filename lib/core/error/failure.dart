// lib/core/error/failures.dart

abstract class Failure {
  final String message;
  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  NetworkFailure({required super.message});
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure({required super.message});
}

class PermissionDeniedFailure extends Failure {
  PermissionDeniedFailure({required super.message});
}

class NotFoundFailure extends Failure {
  NotFoundFailure({required super.message});
}

class InvalidInputFailure extends Failure {
  InvalidInputFailure({required super.message});
}

class TimeoutFailure extends Failure {
  TimeoutFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({required super.message});
}

class DatabaseFailure extends Failure {
  DatabaseFailure({required super.message});
}

class FileNotFoundFailure extends Failure {
  FileNotFoundFailure({required super.message});
}

class InsufficientStorageFailure extends Failure {
  InsufficientStorageFailure({required super.message});
}

class DuplicateEntryFailure extends Failure {
  DuplicateEntryFailure({required super.message});
}

class InvalidCredentialFailure extends Failure {
  InvalidCredentialFailure({required super.message});
}

class OperationCancelledFailure extends Failure {
  OperationCancelledFailure({required super.message});
}
