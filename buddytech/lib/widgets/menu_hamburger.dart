import 'package:flutter/material.dart';

class MenuHamburger extends StatelessWidget {
  final VoidCallback? onTap;

  const MenuHamburger({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(Icons.menu, size: 28, color: Colors.white),
    );
  }
}
