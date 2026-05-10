import 'package:dio/dio.dart';
import 'package:fahis_inspector/core/localization/locale_cubit.dart';
import 'package:fahis_inspector/core/network/api_service.dart';
import 'package:fahis_inspector/core/network/dio_factory.dart';
import 'package:fahis_inspector/core/theme/theme_cubit.dart';
import 'package:fahis_inspector/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:fahis_inspector/features/authentication/domain/repositories/auth_repository.dart';
import 'package:fahis_inspector/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // ── Network ──────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<Dio>(DioFactory.create);
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  // ── App-wide cubits ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
  getIt.registerLazySingleton<LocaleCubit>(LocaleCubit.new);
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );
  // ConnectivityCubit (Task 12), NotificationsCubit (Task 13),
  // OfflineSyncCubit (Task 14)

  // ── Feature repositories (Tasks 17-29) ──────────────────────────────────
}
