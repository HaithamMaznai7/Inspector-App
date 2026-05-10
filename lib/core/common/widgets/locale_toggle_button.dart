import 'package:fahis_inspector/core/localization/locale_cubit.dart';
import 'package:fahis_inspector/core/localization/locale_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleToggleButton extends StatelessWidget {
  const LocaleToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final isArabic = switch (state) {
          LocaleLoaded(:final locale) => locale.languageCode == 'ar',
        };
        return TextButton(
          onPressed: () => context.read<LocaleCubit>().toggle(),
          child: Text(isArabic ? 'EN' : 'عربي'),
        );
      },
    );
  }
}
