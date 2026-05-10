import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

final class ThemeLoaded extends ThemeState {
  const ThemeLoaded(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}
