import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/home/presentation/pages/home_page.dart';
import 'package:spotifly/features/library/presentation/pages/library_page.dart';
import 'package:spotifly/features/search/presentation/pages/search_page.dart';
import 'package:spotifly/features/player/presentation/widgets/mini_player.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/core/theme/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // Pop to first route if tapping the same tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Scaffold(
        body: Stack(
          children: [
            // Using IndexedStack or Offstage Navigators
            // IndexedStack keeps state of all children.
            // But we need safe area logic?
            // Existing pages have SafeArea inside them (e.g. SearchPage).
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                final bool showMiniPlayer = state.currentSong != null;
                final double bottomPadding = showMiniPlayer
                    ? 76.0
                    : 0.0; // 60 height + 16 margin

                return Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      Navigator(
                        key: _navigatorKeys[0],
                        onGenerateRoute: (settings) => MaterialPageRoute(
                          builder: (context) => const HomePage(),
                          settings: settings,
                        ),
                      ),
                      Navigator(
                        key: _navigatorKeys[1],
                        onGenerateRoute: (settings) => MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                          settings: settings,
                        ),
                      ),
                      Navigator(
                        key: _navigatorKeys[2],
                        onGenerateRoute: (settings) => MaterialPageRoute(
                          builder: (context) => const LibraryPage(),
                          settings: settings,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // MiniPlayer on top
            const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                activeIcon: Icon(Icons.search, weight: 800),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music_outlined),
                activeIcon: Icon(Icons.library_music),
                label: 'Your Library',
              ),
            ],
            currentIndex: _selectedIndex,
            backgroundColor: AppColors.bottomNavBackground.withValues(
              alpha: 0.95,
            ),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _onPopInvokedWithResult(didPop, result) {
    if (didPop) return;

    final NavigatorState? currentNavigator =
        _navigatorKeys[_selectedIndex].currentState;

    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
    } else if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
    } else {
      SystemNavigator.pop();
    }
  }
}
