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

  void notify() {
    // Cancelled requests (user navigated away) are silent — not a real error.
    if (isCancelled) return;

    // Suppress 401/403 snackbars when user is authenticated — sessionExpired()
    // will show its own localized message. This prevents duplicate snackbars.
    if ((statusCode == 403) && _isAuthenticatedUser()) {
      return;
    }

    final msg = _formatMessage();

    if (statusCode == 0) {
      FLoader.errorSnackBar(
        title: 'No Connection'.tr,
        message: msg,
        duration: 4,
      );
    } else if (statusCode == 422) {
      FLoader.warningSnackBar(
        title: 'Invalid data'.tr,
        message: msg,
        duration: 5,
      );
    } else if (statusCode == 401) {
      FLoader.warningSnackBar(
        title: 'Unauthenticated'.tr,
        message: msg,
        duration: 4,
      );
    } else if (statusCode == 403) {
      FLoader.warningSnackBar(
        title: 'No Permission'.tr,
        message: msg,
        duration: 4,
      );
    } else if (statusCode == 404) {
      FLoader.errorSnackBar(
        title: 'Not Found'.tr,
        message: msg,
        duration: 4,
      );
    } else if (statusCode == 405) {
      FLoader.warningSnackBar(
        title: 'Method Not Allowed'.tr,
        message: msg,
        duration: 4,
      );
    } else if (statusCode >= 500) {
      FLoader.errorSnackBar(
        title: 'Server Error'.tr,
        message: msg,
        duration: 4,
      );
    } else {
      FLoader.errorSnackBar(
        title: 'Error'.tr,
        message: msg,
        duration: 4,
      );
    }
  }

  /// Builds a user-friendly message from the server response.
  /// Priority: field-level `errors` map → general `message` → fallback.
  String _formatMessage() {
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
    if (message.isNotEmpty) {
      return message;
    }

    // 3. Generic fallback
    return 'Something went wrong, please try again.'.tr;
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

    return FNetworkException(
      response.body['error'] ?? '',
      statusCode: response.statusCode!,
      title: response.body['status'] ?? 'Error',
      errors: response.body['errors'],
    );
  }
}
