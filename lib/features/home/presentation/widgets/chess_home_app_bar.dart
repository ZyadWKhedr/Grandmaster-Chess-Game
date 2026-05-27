import 'package:flutter/material.dart';

class ChessHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ChessHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}