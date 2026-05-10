import 'package:fahis_inspector/core/services/storage/prefs.dart';
import 'package:fahis_inspector/core/localization/locale_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleLoaded(Locale(Prefs.localeCode)));

  Locale get current => (state as LocaleLoaded).locale;

  Future<void> setLocale(Locale locale) async {
    await Prefs.setLocaleCode(locale.languageCode);
    emit(LocaleLoaded(locale));
  }

  Future<void> toggle() async {
    final next = current.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await setLocale(next);
  }
}
