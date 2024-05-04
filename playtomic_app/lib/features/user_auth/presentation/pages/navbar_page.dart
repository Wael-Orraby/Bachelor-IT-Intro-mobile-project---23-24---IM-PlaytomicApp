import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'Clublocaties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer),
          label: 'Wedstrijden',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
      currentIndex: _currentIndex(context),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        _onItemTapped(context, index);
      },
    );
  }

  int _currentIndex(BuildContext context) {
    switch (ModalRoute.of(context)?.settings.name) {
      case '/home':
        return 0;
      case '/club_locations':
        return 1;
      case '/wedstrijden':
        return 2;
      case '/profile':
        return 3;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/club_locations');
        break;
      case 2:
        Navigator.pushNamed(context, '/wedstrijden');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}
