import 'package:dio/dio.dart';
import 'package:fahis_inspector/core/constants/api_endpoints.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  // ── Smoke ────────────────────────────────────────────────────────────────
  @GET(EndPoints.testConnection)
  Future<HttpResponse<dynamic>> testConnection();

  // ── Auth ─────────────────────────────────────────────────────────────────

  @POST(EndPoints.login)
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  // Firebase ID token passed explicitly; AuthInterceptor skips when already set.
  @POST(EndPoints.reauthentication)
  Future<HttpResponse<dynamic>> reauthenticate(
    @Header('Authorization') String authorization,
  );

  @GET(EndPoints.profile)
  Future<HttpResponse<dynamic>> fetchProfile();

  @POST(EndPoints.logout)
  Future<HttpResponse<void>> logout();

  @POST(EndPoints.verifyMobile)
  Future<HttpResponse<dynamic>> sendOtp(@Body() Map<String, dynamic> body);

  // verifyToken and resetToken passed explicitly as Authorization header.
  @POST(EndPoints.verifyOTP)
  Future<HttpResponse<dynamic>> verifyOtp(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );

  @POST(EndPoints.resetPassword)
  Future<HttpResponse<dynamic>> resetPassword(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );

  // ── Notifications (Task 13) ──────────────────────────────────────────────

  // ── Inspections (Tasks 22-29) ────────────────────────────────────────────

  // ── Configuration (Task 18) ──────────────────────────────────────────────
}
