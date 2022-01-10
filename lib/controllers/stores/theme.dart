import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mister/models/interfaces/stores/theme.dart';
import 'package:mister/models/utils/constants.dart';

part 'theme.g.dart';

class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store implements ThemeStoreTemplate {
  @observable
  @override
  bool isDark = false;

  Future<void> _saveTheme(bool theme) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(StoragedValues.theme, theme);
  }

  @action
  @override
  Future<void> changeTheme(bool theme) async {
    _saveTheme(theme).then((_) => isDark = theme);
  }
}
