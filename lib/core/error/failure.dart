// lib/core/error/failures.dart

abstract class Failure {
  final String message;
  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  NetworkFailure({required String message}) : super(message: message);
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure({required String message}) : super(message: message);
}

class PermissionDeniedFailure extends Failure {
  PermissionDeniedFailure({required String message}) : super(message: message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure({required String message}) : super(message: message);
}

class InvalidInputFailure extends Failure {
  InvalidInputFailure({required String message}) : super(message: message);
}

class TimeoutFailure extends Failure {
  TimeoutFailure({required String message}) : super(message: message);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({required String message}) : super(message: message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure({required String message}) : super(message: message);
}

class FileNotFoundFailure extends Failure {
  FileNotFoundFailure({required String message}) : super(message: message);
}

class InsufficientStorageFailure extends Failure {
  InsufficientStorageFailure({required String message})
      : super(message: message);
}

class DuplicateEntryFailure extends Failure {
  DuplicateEntryFailure({required String message}) : super(message: message);
}

class InvalidCredentialFailure extends Failure {
  InvalidCredentialFailure({required String message})
      : super(message: message);
}

class OperationCancelledFailure extends Failure {
  OperationCancelledFailure({required String message})
      : super(message: message);
}
