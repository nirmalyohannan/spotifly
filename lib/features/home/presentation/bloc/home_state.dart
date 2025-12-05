part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Song> recentlyPlayed;
  final List<Playlist> newReleases;

  const HomeLoaded({required this.recentlyPlayed, required this.newReleases});

  @override
  List<Object> get props => [recentlyPlayed, newReleases];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
