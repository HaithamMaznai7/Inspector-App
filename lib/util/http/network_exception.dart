import 'dart:io';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:get/get.dart';

class FNetworkException extends HttpException {
  final String? title;
  final int statusCode;
  final Map<String, dynamic>? errors;

  FNetworkException(
    super.message, {
    this.title,
    this.statusCode = 0,
    this.errors,
  });

  @override
  String toString() {
    return message;
  }

  /// Whether this exception represents a cancelled/aborted request rather than
  /// a real network or server error. These should never be shown to the user.
  bool get isCancelled => statusCode == -1;

  /// Generic message shown for server errors and other non-user-actionable
  /// failures. Never expose raw technical details to the user.
  static String get _genericErrorMessage =>
      'Oops! Something went wrong. Please try again later.'.tr;

  void notify() {
    // Cancelled requests (user navigated away) are silent — not a real error.
    if (isCancelled) return;

    // Suppress 401/403 snackbars when user is authenticated — sessionExpired()
    // will show its own localized message. This prevents duplicate snackbars.
    if ((statusCode == 403) && _isAuthenticatedUser()) {
      return;
    }

    if (statusCode == 0) {
      FLoader.errorSnackBar(
        title: 'No Connection'.tr,
        message: 'Please check your internet connection and try again.'.tr,
        duration: 4,
      );
    } else if (statusCode == 422) {
      // Validation errors — these are meaningful to the user.
      FLoader.warningSnackBar(
        title: 'Invalid data'.tr,
        message: _formatValidationMessage(),
        duration: 5,
      );
    } else if (statusCode == 401) {
      FLoader.warningSnackBar(
        title: 'Session Expired'.tr,
        message: 'Please log in again to continue.'.tr,
        duration: 4,
      );
    } else if (statusCode == 403) {
      FLoader.warningSnackBar(
        title: 'Access Denied'.tr,
        message: 'You don\'t have permission to perform this action.'.tr,
        duration: 4,
      );
    } else if (statusCode == 404) {
      FLoader.errorSnackBar(
        title: 'Not Found'.tr,
        message: 'The requested resource could not be found.'.tr,
        duration: 4,
      );
    } else if (statusCode == 413) {
      FLoader.warningSnackBar(
        title: 'File Too Large'.tr,
        message: 'The image is too large. Please use a smaller image.'.tr,
        duration: 5,
      );
    } else if (statusCode >= 500) {
      // Server errors — NEVER show raw technical details.
      FLoader.errorSnackBar(
        title: 'Something Went Wrong'.tr,
        message: _genericErrorMessage,
        duration: 4,
      );
    } else {
      // Any other unexpected status code — use generic message.
      FLoader.errorSnackBar(
        title: 'Something Went Wrong'.tr,
        message: _genericErrorMessage,
        duration: 4,
      );
    }
  }

  /// Builds a user-friendly message for **validation errors only** (422).
  /// Priority: field-level `errors` map → general `message` → fallback.
  String _formatValidationMessage() {
    // 1. Summarize field-level validation errors (e.g. 422 responses)
    if (errors != null && errors!.isNotEmpty) {
      final lines = <String>[];
      for (final entry in errors!.entries) {
        if (entry.value is List) {
          for (final msg in entry.value) {
            if (msg is String && msg.isNotEmpty) {
              lines.add(msg);
            }
          }
        } else if (entry.value is String && (entry.value as String).isNotEmpty) {
          lines.add(entry.value as String);
        }
      }
      if (lines.isNotEmpty) {
        // Keep it readable — show up to 3 validation messages
        final display = lines.take(3).join('\n');
        if (lines.length > 3) {
          return '$display\n(+${lines.length - 3} more)';
        }
        return display;
      }
    }

    // 2. Fall back to the general error string from the server
    // For validation errors, the server message is usually meaningful.
    if (message.isNotEmpty) {
      return message;
    }

    // 3. Generic fallback
    return 'Please check your input and try again.'.tr;
  }

  /// Check if the user is currently authenticated (has a valid session).
  /// Used to determine if 401/403 errors are session expiry vs. other auth issues.
  static bool _isAuthenticatedUser() {
    try {
      final binding = AuthBinding();
      return binding.isRegistered && binding.instance.isAuth;
    } catch (_) {
      return false;
    }
  }

  factory FNetworkException.set(Response? response) {
    if (response == null || response.statusCode == null) {
      return FNetworkException('', statusCode: -1);
    }

    // Guard: body may be raw HTML/text (e.g. nginx 413) instead of a JSON Map.
    final body = response.body;
    final isMap = body is Map;

    return FNetworkException(
      isMap ? (body['error'] ?? '') : '',
      statusCode: response.statusCode!,
      title: isMap ? (body['status'] ?? 'Error') : 'Error',
      errors: isMap ? (body['errors'] as Map<String, dynamic>?) : null,
    );
  }
}
