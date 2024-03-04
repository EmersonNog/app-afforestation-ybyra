import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/top_to_bottom_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

import '../pages/map_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  Widget get _line => Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        height: 1,
        color: Colors.white.withOpacity(0.2),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/tree_home.png',
              alignment: Alignment.center,
              width: 130,
              height: 130,
            ),
            _line,
            MenuBox(
              padding: const EdgeInsets.symmetric(vertical: 15),
              icon: const Icon(
                Icons.map,
                color: Colors.white,
              ),
              menu: const Text(
                "Mapa",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  PageAnimationTransition(
                    page: const MapScreen(),
                    pageAnimationType: TopToBottomTransition(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuBox extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final Widget menu;
  final Function()? onTap;
  const MenuBox({
    Key? key,
    required this.menu,
    this.padding = const EdgeInsets.all(10),
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: padding,
        child: Row(
          children: [
            icon != null ? icon! : Container(),
            const SizedBox(
              width: 15,
            ),
            menu,
          ],
        ),
      ),
    );
  }
}
