import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/features/settings/presentation/cubit/cache_manager_cubit.dart';
import 'package:spotifly/features/settings/presentation/widgets/cached_song_tile.dart';

class CacheManagerPage extends StatelessWidget {
  const CacheManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CacheManagerCubit>()..loadCachedSongs(),
      child: const CacheManagerView(),
    );
  }
}

class CacheManagerView extends StatelessWidget {
  const CacheManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CacheManagerCubit, CacheManagerState>(
      listener: (context, state) {
        if (state is CacheManagerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Cache Manager',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [_buildSortButton(context), _buildFilterButton(context)],
        ),
        body: Column(
          children: [
            _buildSelectionHeader(context),
            Expanded(
              child: BlocBuilder<CacheManagerCubit, CacheManagerState>(
                builder: (context, state) {
                  if (state is CacheManagerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CacheManagerLoaded) {
                    if (state.filteredSongs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No cached songs found matching your filter.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = state.filteredSongs[index];
                        final isSelected = state.selectedIds.contains(song.id);
                        final selectionMode = state.selectedIds.isNotEmpty;

                        return CachedSongTile(
                          song: song,
                          isSelected: isSelected,
                          selectionMode: selectionMode,
                          onTap: () {
                            if (selectionMode) {
                              context.read<CacheManagerCubit>().toggleSelection(
                                song.id,
                              );
                            }
                          },
                          onLongPress: () {
                            context.read<CacheManagerCubit>().toggleSelection(
                              song.id,
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildSelectionHeader(BuildContext context) {
    return BlocBuilder<CacheManagerCubit, CacheManagerState>(
      builder: (context, state) {
        if (state is CacheManagerLoaded && state.selectedIds.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.selectedIds.length} Selected',
                  style: const TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<CacheManagerCubit>().selectAll(),
                  child: const Text('Select All'),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () =>
                      context.read<CacheManagerCubit>().clearSelection(),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<CacheManagerCubit, CacheManagerState>(
      builder: (context, state) {
        if (state is CacheManagerLoaded) {
          final hasSelection = state.selectedIds.isNotEmpty;
          final totalSize = state.filteredSongs.fold(
            0,
            (sum, item) => sum + item.fileSize,
          );
          final totalSizeStr =
              "${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB";

          final selectionSize = state.filteredSongs
              .where((s) => state.selectedIds.contains(s.id))
              .fold(0, (sum, item) => sum + item.fileSize);
          final selectionSizeStr =
              "${(selectionSize / (1024 * 1024)).toStringAsFixed(1)} MB";

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: hasSelection
                          ? () => _showDeleteDialog(
                              context,
                              count: state.selectedIds.length,
                              sizeStr: selectionSizeStr,
                              isAll: false,
                            )
                          : null, // Disable if no selection? Or behave differently?
                      // Design says: "buttons like delete selected and delete All"
                      // If nothing is selected, maybe only Delete All is visible?
                      // If something selected, Delete Selected is active.
                      // Let's make it simpler: Two buttons if selection?
                      // Or just one responsive button?
                      // Let's follow requirements: "buttons like delete selected and delete All"
                      // I'll put them in a Row if both apply, or stack.
                      child: const Text("Delete Selected"),
                    ),
                  ),
                  if (!hasSelection && state.allSongs.isNotEmpty) ...[
                    // If nothing selected, show Delete All
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withAlpha(180),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _showDeleteDialog(
                          context,
                          count: state.allSongs.length,
                          sizeStr: totalSizeStr,
                          isAll: true,
                        ),
                        child: Text("Delete All"),
                      ),
                    ),
                  ],
                  if (hasSelection) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                        onPressed: () => _showDeleteDialog(
                          context,
                          count: state.allSongs.length,
                          sizeStr: totalSizeStr,
                          isAll: true,
                        ),
                        child: const Text("Delete All"),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort),
      onSelected: (option) {
        context.read<CacheManagerCubit>().sortSongs(option);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: SortOption.dateDesc,
          child: Text("Last Played (Newest)"),
        ),
        const PopupMenuItem(
          value: SortOption.dateAsc,
          child: Text("Last Played (Oldest)"),
        ),
        const PopupMenuItem(
          value: SortOption.sizeDesc,
          child: Text("Size (Largest)"),
        ),
        const PopupMenuItem(
          value: SortOption.sizeAsc,
          child: Text("Size (Smallest)"),
        ),
        const PopupMenuItem(
          value: SortOption.titleAsc,
          child: Text("Title (A-Z)"),
        ),
        const PopupMenuItem(
          value: SortOption.durationDesc,
          child: Text("Duration (Longest)"),
        ),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return PopupMenuButton<TimeRange>(
      icon: const Icon(Icons.filter_list),
      onSelected: (range) {
        context.read<CacheManagerCubit>().filterSongs(timeRange: range);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: TimeRange.all, child: Text("All Time")),
        const PopupMenuItem(
          value: TimeRange.last30Days,
          child: Text("Last 30 Days"),
        ),
        const PopupMenuItem(
          value: TimeRange.last60Days,
          child: Text("Last 60 Days"),
        ),
        const PopupMenuItem(
          value: TimeRange.last90Days,
          child: Text("Last 90 Days"),
        ),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context, {
    required int count,
    required String sizeStr,
    required bool isAll,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Delete from Cache?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will delete $count items and free up $sizeStr.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (isAll) {
                context.read<CacheManagerCubit>().deleteAll();
              } else {
                context.read<CacheManagerCubit>().deleteSelected();
              }
              // De-select mode after delete done handled by cubit ideally, but here we might toggle off if empty?
              context.read<CacheManagerCubit>().clearSelection();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
