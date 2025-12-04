import 'package:flutter/material.dart';
import 'package:spotifly/core/utils/debouncer.dart';
import 'package:spotifly/features/search/presentation/widgets/search_initial_view.dart';
import 'package:spotifly/features/search/presentation/widgets/search_loaded_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/search/data/repositories/search_repository_impl.dart';
import 'package:spotifly/features/search/presentation/bloc/search_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(searchRepository: SearchRepositoryImpl()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: 500);
    _focusNode.addListener(() {
      setState(() {
        _isSearching = _focusNode.hasFocus || _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Artists, songs, or podcasts',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchBloc>().add(
                                const SearchQueryChanged(''),
                              );
                              _focusNode.unfocus();
                              setState(() {
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    _debouncer.run(() {
                      if (value.length >= 2) {
                        context.read<SearchBloc>().add(
                          SearchQueryChanged(value),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchLoaded) {
                    if (state.results.songs.isEmpty &&
                        state.results.playlists.isEmpty) {
                      return const Center(child: Text('No results found'));
                    }
                    return SearchLoadedView(results: state.results);
                  } else if (state is SearchError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  // Default view (Categories)
                  return SearchInitialView();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
