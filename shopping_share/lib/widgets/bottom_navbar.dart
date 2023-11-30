import 'package:flutter/material.dart';

import 'package:shopping_share/theme.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    void onItemTapped(int index) {
      if (currentIndex == index) return;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/shopping_lists');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/account');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double iconHeightScalingMultiplier = 0.05;
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: SizedBox(
              height: screenHeight * iconHeightScalingMultiplier,
              child: Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Image.asset("assets/images/list.png")),
            ),
            label: ''),
        BottomNavigationBarItem(
            icon: SizedBox(
              height: screenHeight * iconHeightScalingMultiplier,
              child: Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Image.asset("assets/images/human.png")),
            ),
            label: ''),
        BottomNavigationBarItem(
            icon: SizedBox(
              height: screenHeight * iconHeightScalingMultiplier,
              child: Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Image.asset("assets/images/settings.png")),
            ),
            label: ''),
      ],
      currentIndex: currentIndex,
      unselectedItemColor: const Color.fromARGB(255, 225, 225, 225),
      backgroundColor: primaryColor,
      selectedItemColor: bottomBarSelectedColor,
      onTap: onItemTapped,
    );
  }
}
