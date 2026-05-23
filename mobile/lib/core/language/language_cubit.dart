import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../security/secure_storage.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit(this._storage) : super(const Locale('fr'));

  final SecureStorageService _storage;
  static const _kLocaleKey = 'user_locale';

  Future<void> load() async {
    final code = await _storage.read(key: _kLocaleKey);
    if (code != null) emit(Locale(code));
  }

  Future<void> change(Locale locale) async {
    await _storage.write(key: _kLocaleKey, value: locale.languageCode);
    emit(locale);
  }
}
