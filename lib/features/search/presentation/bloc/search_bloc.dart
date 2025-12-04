import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotifly/features/search/domain/entities/search_results.dart';
import 'package:spotifly/features/search/domain/repositories/search_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;

  SearchBloc({required this.searchRepository}) : super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final results = await searchRepository.search(event.query);
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
