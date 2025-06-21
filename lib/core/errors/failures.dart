import 'package:cycle_tracker_app/dependencies.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? errorCode;

  const Failure({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// Database-related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.errorCode});
}

/// Network-related failures (if needed in future)
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.errorCode});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.errorCode});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.errorCode});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.errorCode});
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.errorCode});
}

/// Generic server failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.errorCode});
}

/// Unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.errorCode});
}
