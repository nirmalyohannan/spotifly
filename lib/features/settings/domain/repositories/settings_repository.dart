import 'package:spotifly/features/settings/domain/entities/user_profile.dart';

abstract class SettingsRepository {
  Future<UserProfile> getProfile();
}
