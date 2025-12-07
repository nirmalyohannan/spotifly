import 'package:spotifly/features/settings/domain/entities/user_profile.dart';
import 'package:spotifly/features/settings/domain/repositories/settings_repository.dart';

class GetUserProfile {
  final SettingsRepository repository;

  GetUserProfile(this.repository);

  Future<UserProfile> call() async {
    return repository.getProfile();
  }
}
