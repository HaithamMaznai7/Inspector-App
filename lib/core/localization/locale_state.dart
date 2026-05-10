import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

sealed class LocaleState extends Equatable {
  const LocaleState();

  @override
  List<Object?> get props => [];
}

final class LocaleLoaded extends LocaleState {
  const LocaleLoaded(this.locale);

  final Locale locale;

  @override
  List<Object?> get props => [locale];
}
