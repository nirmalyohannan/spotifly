import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/features/library/presentation/bloc/library_view_cubit.dart';
import 'package:spotifly/features/library/presentation/widgets/library_grid_view.dart';
import 'package:spotifly/features/library/presentation/widgets/library_list_view.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';
import 'package:spotifly/shared/presentation/widgets/pill.dart';
import 'package:spotifly/features/settings/presentation/pages/settings_page.dart';
import '../bloc/playlist_bloc.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              PlaylistBloc(playlistRepository: getIt<PlaylistRepository>())
                ..add(LoadPlaylists()),
        ),
        BlocProvider(create: (context) => LibraryViewCubit()),
      ],
      child: Scaffold(
        appBar: const LibraryAppBar(),
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
                                  likedSongsCount:
                                      playlistState.likedSongsCount,
                                )
                              : LibraryGridView(
                                  key: const ValueKey('Grid'),
                                  playlists: playlistState.playlists,
                                  likedSongsCount:
                                      playlistState.likedSongsCount,
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
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<String?>(
            future: getIt<PlaylistRepository>().getUserProfileImage(),
            builder: (context, snapshot) {
              final imageUrl = snapshot.data;
              return CircleAvatar(
                backgroundColor: Colors.grey[800],
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              );
            },
          ),
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
