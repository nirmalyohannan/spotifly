import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/features/auth/presentation/pages/login_page.dart';
import 'package:spotifly/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:spotifly/features/settings/presentation/bloc/settings_event.dart';
import 'package:spotifly/features/settings/presentation/bloc/settings_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/settings/presentation/pages/cache_manager_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(LoadProfile()),
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            context.read<PlayerBloc>().add(ResetPlayer());
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CacheClearedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Audio cache cleared successfully')),
            );
            // Reload profile to restore view
            context.read<SettingsBloc>().add(LoadProfile());
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SettingsLoaded) {
                final profile = state.profile;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: ClipOval(
                          child: profile.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: profile.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white54,
                                      ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white54,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Info Cards
                      _buildInfoTile('Country', profile.country),
                      _buildInfoTile(
                        'Subscription',
                        profile.product.toUpperCase(),
                      ),

                      const SizedBox(height: 24),
                      // Storage Section / Clear Cache
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CacheManagerPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Manage Audio Cache',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<SettingsBloc>().add(LogoutRequested());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
