import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/shared/data/repositories/playlist_repository_impl.dart';
import 'package:spotifly/features/library/presentation/bloc/library_view_cubit.dart';
import 'package:spotifly/features/library/presentation/widgets/library_grid_view.dart';
import 'package:spotifly/features/library/presentation/widgets/library_list_view.dart';
import 'package:spotifly/shared/presentation/widgets/pill.dart';
import '../bloc/playlist_bloc.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              PlaylistBloc(playlistRepository: PlaylistRepositoryImpl())
                ..add(LoadPlaylists()),
        ),
        BlocProvider(create: (context) => LibraryViewCubit()),
      ],
      child: Scaffold(
        appBar: LibraryAppBar(),
        body: Column(
          children: [
            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Pill('Playlists'),
                  const SizedBox(width: 8),
                  Pill('Artists'),
                  const SizedBox(width: 8),
                  Pill('Albums'),
                  const SizedBox(width: 8),
                  Pill('Podcasts & shows'),
                ],
              ),
            ),

            // Sort Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Recently played',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<LibraryViewCubit, LibraryViewMode>(
                    builder: (context, mode) {
                      return IconButton(
                        icon: Icon(
                          mode == LibraryViewMode.list
                              ? Icons.grid_view
                              : Icons.list,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.read<LibraryViewCubit>().toggleViewMode();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // List / Grid
            Expanded(
              child: BlocBuilder<PlaylistBloc, PlaylistState>(
                builder: (context, playlistState) {
                  if (playlistState is PlaylistLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (playlistState is PlaylistLoaded) {
                    return BlocBuilder<LibraryViewCubit, LibraryViewMode>(
                      builder: (context, viewMode) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          child: viewMode == LibraryViewMode.list
                              ? LibraryListView(
                                  key: const ValueKey('List'),
                                  playlists: playlistState.playlists,
                                )
                              : LibraryGridView(
                                  key: const ValueKey('Grid'),
                                  playlists: playlistState.playlists,
                                ),
                        );
                      },
                    );
                  } else if (playlistState is PlaylistError) {
                    return Center(child: Text(playlistState.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LibraryAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: (context, state) {
            String? imageUrl;
            if (state is PlaylistLoaded) {
              imageUrl = state.userProfileImage;
            }
            return CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl:
                      imageUrl ?? 'https://avatar.iran.liara.run/public/7',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      title: const Text(
        'Your Library',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(icon: const Icon(Icons.add), onPressed: () {}),
      ],
    );
  }
}
