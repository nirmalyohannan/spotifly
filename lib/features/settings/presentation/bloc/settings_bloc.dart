import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/settings/domain/usecases/get_user_profile.dart';
import 'package:spotifly/features/settings/domain/usecases/logout_user.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetUserProfile getUserProfile;
  final LogoutUser logoutUser;

  SettingsBloc({required this.getUserProfile, required this.logoutUser})
    : super(SettingsInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(SettingsLoading());
      try {
        final profile = await getUserProfile();
        emit(SettingsLoaded(profile));
      } catch (e) {
        emit(SettingsError('Failed to load profile: $e'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(SettingsLoading());
      try {
        await logoutUser();
        emit(LogoutSuccess());
      } catch (e) {
        emit(SettingsError('Failed to logout: $e'));
      }
    });
  }
}
