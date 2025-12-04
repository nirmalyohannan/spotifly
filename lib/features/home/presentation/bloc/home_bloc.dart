import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotifly/features/home/domain/repositories/home_repository.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final recentlyPlayed = await homeRepository.getRecentlyPlayed();
      final featuredPlaylists = await homeRepository.getFeaturedPlaylists();
      final newReleases = await homeRepository.getNewReleases();

      emit(
        HomeLoaded(
          recentlyPlayed: recentlyPlayed,
          featuredPlaylists: featuredPlaylists,
          newReleases: newReleases,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
