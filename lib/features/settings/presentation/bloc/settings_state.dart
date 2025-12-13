import 'package:spotifly/features/settings/domain/entities/user_profile.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserProfile profile;
  SettingsLoaded(this.profile);
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}

class LogoutSuccess extends SettingsState {}

class CacheClearedSuccess extends SettingsState {}
