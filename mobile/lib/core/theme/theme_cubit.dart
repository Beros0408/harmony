import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../security/secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(ThemeMode.system);

  final SecureStorageService _storage;
  static const _kThemeKey = 'user_theme_mode';

  Future<void> load() async {
    final saved = await _storage.read(key: _kThemeKey);
    final resolved = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => null,
    };
    if (resolved != null) emit(resolved);
  }

  Future<void> change(ThemeMode mode) async {
    await _storage.write(
      key: _kThemeKey,
      value: switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
    emit(mode);
  }
}
