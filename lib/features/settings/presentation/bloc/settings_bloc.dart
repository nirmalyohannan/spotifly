import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/settings/domain/usecases/get_user_profile.dart';
import 'package:spotifly/features/settings/domain/usecases/logout_user.dart';
import 'package:spotifly/features/settings/domain/usecases/clear_audio_cache.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetUserProfile getUserProfile;
  final LogoutUser logoutUser;
  final ClearAudioCache clearAudioCache;

  SettingsBloc({
    required this.getUserProfile,
    required this.logoutUser,
    required this.clearAudioCache,
  }) : super(SettingsInitial()) {
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

    on<ClearCacheRequested>((event, emit) async {
      // Keep showing loading or keep current state?
      // Better to show loading or a toast.
      // Usually we want to stay on the page.
      // Easiest is to emit Loading then go back to Loaded if possible, or just emit Success side effect.
      // But Bloc state is single. If we emit Success, we lose the Profile data in UI if checking `state is SettingsLoaded`.
      // The UI uses `SettingsLoaded` to show profile.
      // WE NEED TO BE CAREFUL.
      // If we emit CacheClearedSuccess, the UI builder might switch away from the profile view.

      // Strategy:
      // We can emit a state that conceptually contains the profile AND the success message, OR
      // we treat `CacheClearedSuccess` as a specialized state and the UI handles it by showing snackbar and then we reload profile?
      // OR we just assume `ClearCache` is quick.

      // Let's do:
      // 1. Loading (optional)
      // 2. await clearAudioCache()
      // 3. Emit `CacheClearedSuccess`
      // 4. Trace back to `LoadProfile`?

      // Issue: If `CacheClearedSuccess` replaces `SettingsLoaded`, the screen might flicker or go blank.
      // Better: In `BlocListener` verify `state is CacheClearedSuccess`, then `add(LoadProfile())`.

      emit(SettingsLoading());
      try {
        await clearAudioCache();
        emit(CacheClearedSuccess());
        // After emitting success, we should probably reload the profile or go back to loaded state
        // Triggering reload via event is cleaner from UI listener.
      } catch (e) {
        emit(SettingsError('Failed to clear cache: $e'));
      }
    });
  }
}
