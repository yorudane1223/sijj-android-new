import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sijj_provinsi_banten/data/sidebar.dart';
import 'package:sijj_provinsi_banten/functions/auth_function.dart';
import 'package:sijj_provinsi_banten/pages/coordinate_page.dart';
import 'package:sijj_provinsi_banten/pages/home_page.dart';
import 'package:sijj_provinsi_banten/pages/map_page.dart';
import 'package:sijj_provinsi_banten/tabs/absen_tab.dart';
import 'package:sijj_provinsi_banten/tabs/my_profile_tab.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    return Drawer(
      backgroundColor: primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/batik.jpeg'),
                  fit: BoxFit.cover),
              color: Color.fromARGB(255, 233, 233, 233),
            ),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.network(
                        user!.image,
                        // 'assets/images/banten-logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(user.email,
                          style: poppins.copyWith(
                              color: Colors.white, fontSize: 12)),
                      Text(
                        user.nama,
                        style: poppins.copyWith(color: Colors.white),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          ...sidebarMenu.map(
            (e) => ListTile(
              leading: SvgPicture.asset(
                'assets/icons/${e.icon}',
                // ignore: deprecated_member_use
                color: e.color,
              ),
              title: Text(
                e.name,
                style: poppins.copyWith(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  // Return the appropriate page based on e.page
                  // ignore: unrelated_type_equality_checks
                  if (e.page == 'HomePage') {
                    return const HomePage();
                    // ignore: unrelated_type_equality_checks
                  } else if (e.page == 'MapTab') {
                    return const MapPage();
                  } else if (e.page == 'AbsenTab') {
                    return const AbsenTab();
                  } else if (e.page == 'MyProfileTab') {
                    return const MyProfileTab();
                  } else if (e.page == 'MapPage') {
                    return const MapPage();
                  } else if (e.page == 'CoordinatePage') {
                    return const CoordinatePage();
                  }
                  throw Exception("Unknown page: ${e.page}");
                }));
              },
            ),
          )
        ],
      ),
    );
  }
}
