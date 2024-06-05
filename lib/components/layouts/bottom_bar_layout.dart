import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sijj_provinsi_banten/pages/home_page.dart';
import 'package:sijj_provinsi_banten/tabs/attendance_tab.dart';
import 'package:sijj_provinsi_banten/tabs/map_tab.dart';
import 'package:sijj_provinsi_banten/tabs/my_profile_tab.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';

class BottomBarLayout extends StatefulWidget {
  const BottomBarLayout({super.key});

  @override
  State createState() => _BottomBarLayoutState();
}

class _BottomBarLayoutState extends State<BottomBarLayout> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      animationDuration: const Duration(seconds: 3),
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapTab()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AttendanceTab()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyProfileTab()),
          );
        }
      },
      indicatorColor: primary,
      selectedIndex: currentPageIndex,
      destinations: <Widget>[
        NavigationDestination(
          selectedIcon:
              // ignore: deprecated_member_use
              SvgPicture.asset('assets/icons/home.svg', color: Colors.white),
          icon: SvgPicture.asset('assets/icons/home.svg'),
          label: 'Beranda',
        ),
        NavigationDestination(
          selectedIcon: SvgPicture.asset(
            'assets/icons/absen.svg',
            // ignore: deprecated_member_use
            color: Colors.white,
          ),
          icon: SvgPicture.asset('assets/icons/absen.svg'),
          label: 'Absen',
        ),
        NavigationDestination(
          selectedIcon: SvgPicture.asset(
            'assets/icons/profile.svg',
            // ignore: deprecated_member_use
            color: Colors.white,
          ),
          icon: SvgPicture.asset('assets/icons/profile.svg'),
          label: 'Profil',
        ),
      ],
    );
  }
}
