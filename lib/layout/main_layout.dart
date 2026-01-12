import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/chats_screen.dart';
import '../screen/favorites_screen.dart';

// add more screens later

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    Placeholder(), // Favorites
    Placeholder(), // Search
    Placeholder(), // Chats
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      /// 🌟 SHARED BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        // 🔧 DARKER WHITE (your request)
        backgroundColor: const Color(0xFFF3F4F6),
        selectedItemColor: const Color(0xFFFF6900),
        unselectedItemColor: const Color(0xFF9CA3AF),

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
