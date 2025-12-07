import 'package:flutter/material.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class PlayerAppbar extends StatelessWidget implements PreferredSizeWidget {
  const PlayerAppbar({super.key, required this.song});

  final Song? song;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(),
      ),
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        song?.album ?? '',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }
}
