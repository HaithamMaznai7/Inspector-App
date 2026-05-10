import 'package:fahis_inspector/core/theme/theme_cubit.dart';
import 'package:fahis_inspector/core/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = switch (state) {
          ThemeLoaded(:final themeMode) => themeMode == ThemeMode.dark ||
              (themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark),
        };
        return IconButton(
          icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          onPressed: () => context.read<ThemeCubit>().toggle(),
        );
      },
    );
  }
}
