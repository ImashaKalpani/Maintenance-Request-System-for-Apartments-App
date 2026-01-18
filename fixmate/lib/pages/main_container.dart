import 'package:flutter/material.dart';
import 'home_page.dart';
import 'request_page.dart';
import 'call_page.dart';
import 'profile_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomePage(),
    RequestsPage(),
    EmergencySupportPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F9FA),
      child: Column(
        children: [
          // Main content area (takes all available space except navbar)
          Expanded(child: _pages[_index]),

          // Bottom navigation bar (fixed at bottom)
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: const Color(0xFF00A8C6),
                unselectedItemColor: Colors.black45,
                selectedFontSize: 13,
                unselectedFontSize: 13,
                showUnselectedLabels: true,
                items: [
                  _navItem(icon: Icons.home_rounded, label: "Home", index: 0),
                  _navItem(
                    icon: Icons.list_alt_rounded,
                    label: "Requests",
                    index: 1,
                  ),
                  _navItem(icon: Icons.call_rounded, label: "Call", index: 2),
                  _navItem(
                    icon: Icons.person_rounded,
                    label: "Profile",
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = index == _index;
    final Color activeColor = const Color(0xFF00A8C6);
    final Color inactiveColor = Colors.black45;

    return BottomNavigationBarItem(
      label: label,
      icon: Container(
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: activeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              )
            : null,
        child: Icon(
          icon,
          size: isActive ? 26 : 22,
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}
