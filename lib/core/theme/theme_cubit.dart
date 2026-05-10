import 'package:fahis_inspector/core/services/storage/prefs.dart';
import 'package:fahis_inspector/core/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeLoaded(_resolveInitial()));

  static ThemeMode _resolveInitial() => switch (Prefs.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  ThemeMode get current => (state as ThemeLoaded).themeMode;

  Future<void> setTheme(ThemeMode mode) async {
    final key = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await Prefs.setThemeMode(key);
    emit(ThemeLoaded(mode));
  }

  Future<void> toggle() async {
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }
}
