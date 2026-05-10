import 'package:equatable/equatable.dart';

class ApiErrorModel extends Equatable {
  final int statusCode;
  final String message;
  final Map<String, List<String>>? validationErrors;
  final bool isCancelled;

  const ApiErrorModel({
    this.statusCode = 0,
    required this.message,
    this.validationErrors,
    this.isCancelled = false,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidation => statusCode == 422;
  bool get isNoConnection => statusCode == 0 && !isCancelled;
  bool get isServerError => statusCode >= 500;

  /// Flattens validation errors into a single user-readable string.
  /// Returns at most [maxLines] messages joined by newlines.
  String validationMessage({int maxLines = 3}) {
    final errors = validationErrors;
    if (errors == null || errors.isEmpty) return message;
    final lines = errors.values.expand((msgs) => msgs).take(maxLines).toList();
    return lines.join('\n');
  }

  @override
  List<Object?> get props => [statusCode, message, validationErrors, isCancelled];
}
