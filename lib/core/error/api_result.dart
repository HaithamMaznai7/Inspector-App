import 'api_error_model.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiResultSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiResultSuccess(this.data);
}

final class ApiResultFailure<T> extends ApiResult<T> {
  final ApiErrorModel error;
  const ApiResultFailure(this.error);
}
